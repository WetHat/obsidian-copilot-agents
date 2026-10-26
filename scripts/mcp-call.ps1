#Requires -Version 7.0
<#
.SYNOPSIS
    Generic caller for MCP tools registered in copilot/opencode.json.

.DESCRIPTION
    MCP tools are only invocable from the Code Mode `execute` sandbox, which has
    no filesystem access. Any tool needing a file's contents therefore requires
    inlining that content as a string literal, and that transport is the weak
    point: large single-line payloads have been observed arriving corrupted, and
    the sandbox has no crypto.subtle to verify them. It also has a `Uint8Array.from`
    polyfill that silently zero-fills string sources.

    This script sidesteps all of it: the file is read from disk here and sent
    over the server's own transport. One entry point serves every HTTP MCP
    server, so no per-tool wrapper is needed.

    Only `remote` (HTTP/SSE) servers are supported. `local` servers are stdio
    child processes and need a different transport.

.PARAMETER Tool
    MCP tool name, e.g. infer_content_type.

.PARAMETER Server
    Server name under mcp.servers in the config. Defaults to windmill.

.PARAMETER Arg
    Tool argument as name=value. A value beginning with @ reads that file:
      -Arg 'content=@AI/Agents/Foo.md'   -> argument `content` = file text
    Repeat for multiple arguments.

.PARAMETER StripFrontmatter
    Remove YAML frontmatter from any @file argument.

.PARAMETER ListTools
    Print the server's tools and exit.

.PARAMETER Raw
    Print the tool's text response verbatim instead of re-serialised JSON.

.EXAMPLE
    pwsh copilot/scripts/mcp-call.ps1 -ListTools

.EXAMPLE
    pwsh copilot/scripts/mcp-call.ps1 -Tool infer_content_type -Arg 'content=@AI/Agents/Foo.md'

.EXAMPLE
    pwsh copilot/scripts/mcp-call.ps1 -Tool scrape_markdown_article -Server firecrawl -Arg 'url=https://example.com'
#>
[CmdletBinding()]
param(
    [string]$Tool,
    [string]$Server = 'windmill',
    [string[]]$Arg = @(),
    [switch]$StripFrontmatter,
    [switch]$ListTools,
    [switch]$Raw,
    [string]$ConfigPath,
    [string]$VaultRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if (-not $ConfigPath) { $ConfigPath = Join-Path $VaultRoot 'copilot/opencode.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Config not found: $ConfigPath" }

# --- resolve the server -----------------------------------------------------
$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$servers = $cfg.mcp.servers
if (-not $servers) { throw "No mcp.servers in $ConfigPath" }

$srv = $servers.PSObject.Properties[$Server]
if (-not $srv) {
    $names = ($servers.PSObject.Properties.Name) -join ', '
    throw "Unknown MCP server '$Server'. Available: $names"
}
$def = $srv.Value

if ($def.type -ne 'remote') {
    throw "Server '$Server' is type '$($def.type)' (stdio child process). This helper speaks HTTP MCP only; use execute for that server."
}
$uri = $def.url
if (-not $uri) { throw "Server '$Server' has no url." }

# --- resolve placeholders like {env:WINDMILL_MCP_TOKEN} ---------------------
function Resolve-EnvPlaceholder {
    param([string]$Name)

    $v = [Environment]::GetEnvironmentVariable($Name)
    if ($v) { return $v }

    # Fall back to the value stored in the Copilot plugin settings.
    $pluginCfg = Join-Path $VaultRoot '.obsidian/plugins/copilot/data.json'
    if (Test-Path -LiteralPath $pluginCfg) {
        $m = [regex]::Match([IO.File]::ReadAllText($pluginCfg), '"' + [regex]::Escape($Name) + '"\s*:\s*"([^"]+)"')
        if ($m.Success) { return $m.Groups[1].Value }
    }
    throw "Cannot resolve environment placeholder '$Name'."
}

$headers = @{ Accept = 'application/json, text/event-stream' }
if ($def.headers) {
    foreach ($h in $def.headers.PSObject.Properties) {
        $headers[$h.Name] = [regex]::Replace([string]$h.Value, '\{env:([^}]+)\}', {
                param($m) Resolve-EnvPlaceholder $m.Groups[1].Value
            })
    }
}

# --- JSON-RPC over HTTP/SSE -------------------------------------------------
function Invoke-McpRpc {
    param([Parameter(Mandatory)][hashtable]$Payload)

    $json  = $Payload | ConvertTo-Json -Depth 15 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)

    $resp = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers `
        -ContentType 'application/json; charset=utf-8' -Body $bytes -TimeoutSec 180

    $data = ($resp.Content -split "`r?`n" |
        Where-Object { $_ -like 'data: *' } |
        ForEach-Object { $_.Substring(6) }) -join ''

    if (-not $data) { throw "Empty MCP response (HTTP $($resp.StatusCode))" }
    $parsed = $data | ConvertFrom-Json
    if ($parsed.error) { throw "MCP error $($parsed.error.code): $($parsed.error.message)" }
    return $parsed.result
}

if ($ListTools) {
    $r = Invoke-McpRpc @{ jsonrpc = '2.0'; id = 1; method = 'tools/list'; params = @{} }
    $r.tools | ForEach-Object { "{0}`t{1}" -f $_.name, (($_.description -split "`r?`n")[0]) }
    return
}

if (-not $Tool) { throw 'Specify -Tool, or -ListTools to discover them.' }

# --- build arguments --------------------------------------------------------
$arguments = @{}
foreach ($pair in $Arg) {
    $eq = $pair.IndexOf('=')
    if ($eq -lt 1) { throw "Bad -Arg '$pair'. Expected name=value." }

    $name  = $pair.Substring(0, $eq)
    $value = $pair.Substring($eq + 1)

    if ($value.StartsWith('@')) {
        $file = $value.Substring(1)
        if (-not [IO.Path]::IsPathRooted($file)) { $file = Join-Path $VaultRoot $file }
        if (-not (Test-Path -LiteralPath $file)) { throw "Argument file not found: $file" }

        $text = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $file).Path, [Text.UTF8Encoding]::new($false))
        if ($StripFrontmatter) { $text = $text -replace '(?s)^---\r?\n.*?\r?\n---\r?\n', '' }
        $value = $text
    }
    $arguments[$name] = $value
}

$result = Invoke-McpRpc @{
    jsonrpc = '2.0'
    id      = 2
    method  = 'tools/call'
    params  = @{ name = $Tool; arguments = $arguments }
}

if ($result.isError) {
    $msg = ($result.content | Where-Object { $_.type -eq 'text' }).text
    throw "Tool '$Tool' failed: $msg"
}

$text = ($result.content | Where-Object { $_.type -eq 'text' }).text
if (-not $text) { throw "Tool '$Tool' returned no text content." }

if ($Raw) { $text }
else {
    try   { $text | ConvertFrom-Json | ConvertTo-Json -Depth 15 }
    catch { $text }
}
