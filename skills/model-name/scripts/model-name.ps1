<#
.SYNOPSIS
  Return the model that executes the current OpenCode session.
.DESCRIPTION
  Reads OPENCODE_SESSION_ID (or -SessionId), queries the local OpenCode SQLite
  database read-only through Microsoft.Data.Sqlite, and returns the model of the
  session's latest assistant message. It knows nothing about any note; the
  caller decides what to do with the result.
.PARAMETER SessionId
  OpenCode session ID. Defaults to $env:OPENCODE_SESSION_ID.
.PARAMETER Database
  Path to opencode.db. Defaults to the local OpenCode data directory.
.PARAMETER SqliteRoot
  NuGet package root holding Microsoft.Data.Sqlite and SQLitePCLRaw. Defaults
  to $env:NUGET_PACKAGES or %USERPROFILE%\.nuget\packages.
.PARAMETER ShortModelName
  Report the provider-stripped model name (for example
  deepseek-v4.1-flash-1017) instead of the exact session model ID.
.PARAMETER Json
  Emit one JSON object instead of the human-readable report.
#>
[CmdletBinding()]
param(
  [string] $SessionId = $env:OPENCODE_SESSION_ID,
  [string] $Database,
  [string] $SqliteRoot,
  [switch] $ShortModelName,
  [switch] $Json
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$InstallHint = @'
Install it with the .NET SDK:

  $dir = Join-Path $env:TEMP 'model-name-sqlite'
  dotnet new console -o $dir --force
  dotnet add $dir package Microsoft.Data.Sqlite
  Remove-Item $dir -Recurse -Force

The packages are cached in %USERPROFILE%\.nuget\packages. Use -SqliteRoot to
point at a different NuGet package root. If dotnet is not installed, install
the .NET SDK first: https://dotnet.microsoft.com/download
'@

function Fail([string] $Message, [int] $Code = 1, [string] $Detail) {
  [Console]::Error.WriteLine("model-name: $Message")
  if ($Detail) {
    [Console]::Error.WriteLine('')
    [Console]::Error.WriteLine($Detail)
  }
  exit $Code
}

function Get-LatestPackage([string] $Root, [string] $Name) {
  $directory = Join-Path $Root $Name
  if (-not (Test-Path -LiteralPath $directory -PathType Container)) { return $null }
  return Get-ChildItem -LiteralPath $directory -Directory |
    Where-Object { $_.Name -match '^\d+(\.\d+)+$' } |
    Sort-Object { [version]$_.Name } -Descending |
    Select-Object -First 1
}

function Get-SqliteAssemblies([string] $Root) {
  if (-not $Root) {
    $Root = if ($env:NUGET_PACKAGES) {
      $env:NUGET_PACKAGES
    }
    else {
      Join-Path $env:USERPROFILE '.nuget\packages'
    }
  }
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) { return $null }

  $mds = Get-LatestPackage -Root $Root -Name 'microsoft.data.sqlite.core'
  $core = Get-LatestPackage -Root $Root -Name 'sqlitepclraw.core'
  $provider = Get-LatestPackage -Root $Root -Name 'sqlitepclraw.provider.e_sqlite3'
  $batteries = Get-LatestPackage -Root $Root -Name 'sqlitepclraw.bundle_e_sqlite3'
  $nativePackage = Get-LatestPackage -Root $Root -Name 'sqlitepclraw.lib.e_sqlite3'
  if (-not $mds -or -not $core -or -not $provider -or -not $batteries -or -not $nativePackage) {
    return $null
  }

  $mdsDll = $null
  foreach ($tfm in @('net10.0', 'net9.0', 'net8.0', 'netstandard2.0')) {
    $candidate = Join-Path $mds.FullName "lib\$tfm\Microsoft.Data.Sqlite.dll"
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      $mdsDll = $candidate
      break
    }
  }

  $coreDll = Join-Path $core.FullName 'lib\netstandard2.0\SQLitePCLRaw.core.dll'

  $providerDll = $null
  foreach ($tfm in @('net6.0-windows7.0', 'net6.0', 'netstandard2.0')) {
    $candidate = Join-Path $provider.FullName "lib\$tfm\SQLitePCLRaw.provider.e_sqlite3.dll"
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      $providerDll = $candidate
      break
    }
  }

  $batteriesDll = Join-Path $batteries.FullName 'lib\netstandard2.0\SQLitePCLRaw.batteries_v2.dll'

  $architecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString()
  $runtime = switch ($architecture) {
    'X64' { 'win-x64' }
    'Arm64' { 'win-arm64' }
    'X86' { 'win-x86' }
    default { 'win-x64' }
  }
  $nativeDll = Join-Path $nativePackage.FullName "runtimes\$runtime\native\e_sqlite3.dll"

  foreach ($candidate in @($mdsDll, $coreDll, $providerDll, $batteriesDll, $nativeDll)) {
    if (-not $candidate -or -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
      return $null
    }
  }

  return [pscustomobject]@{
    MicrosoftDataSqlite = $mdsDll
    Core = $coreDll
    Provider = $providerDll
    Batteries = $batteriesDll
    Native = $nativeDll
    NativeDir = Split-Path -Parent $nativeDll
    Root = $Root
  }
}

function Initialize-Sqlite($Assemblies) {
  $env:PATH = "$($Assemblies.NativeDir);$env:PATH"
  if (-not ('SQLitePCL.Batteries_V2' -as [type])) {
    Add-Type -Path $Assemblies.Core | Out-Null
    Add-Type -Path $Assemblies.Provider | Out-Null
    Add-Type -Path $Assemblies.Batteries | Out-Null
  }
  if (-not ('Microsoft.Data.Sqlite.SqliteConnection' -as [type])) {
    Add-Type -Path $Assemblies.MicrosoftDataSqlite | Out-Null
  }
  [SQLitePCL.Batteries_V2]::Init()
}

function ConvertTo-IsoDate([Int64] $Milliseconds) {
  if ($Milliseconds -le 0) { return $null }
  return [DateTimeOffset]::FromUnixTimeMilliseconds($Milliseconds).ToLocalTime().ToString('yyyy-MM-ddTHH:mm:sszzz')
}

function Get-SessionRecord($Connection, [string] $SessionId) {
  $command = $Connection.CreateCommand()
  $reader = $null
  try {
    $command.CommandText = @'
select id, title, model, time_created, time_updated
from session_v2
where id = $sid
'@
    [void]$command.Parameters.AddWithValue('$sid', $SessionId)
    $reader = $command.ExecuteReader()
    if (-not $reader.Read()) { return $null }

    $title = $null
    if (-not $reader.IsDBNull(1)) { $title = $reader.GetString(1) }
    $model = $null
    if (-not $reader.IsDBNull(2)) { $model = $reader.GetString(2) }

    return [pscustomobject]@{
      id = $reader.GetString(0)
      title = $title
      model = $model
      time_created = $reader.GetInt64(3)
      time_updated = $reader.GetInt64(4)
    }
  }
  finally {
    if ($reader) { $reader.Dispose() }
    $command.Dispose()
  }
}

function Get-MessageModel($Connection, [string] $SessionId, [string] $Type) {
  $command = $Connection.CreateCommand()
  $reader = $null
  try {
    $command.CommandText = @'
select json_extract(data, '$.model.id') as model,
       json_extract(data, '$.model.providerID') as provider,
       json_extract(data, '$.model.variant') as variant,
       time_created
from session_message
where session_id = $sid and type = $type
order by seq desc
limit 1
'@
    [void]$command.Parameters.AddWithValue('$sid', $SessionId)
    [void]$command.Parameters.AddWithValue('$type', $Type)
    $reader = $command.ExecuteReader()
    if (-not $reader.Read()) { return $null }

    $model = $null
    if (-not $reader.IsDBNull(0)) { $model = $reader.GetString(0) }
    $provider = $null
    if (-not $reader.IsDBNull(1)) { $provider = $reader.GetString(1) }
    $variant = $null
    if (-not $reader.IsDBNull(2)) { $variant = $reader.GetString(2) }

    return [pscustomobject]@{
      model = $model
      provider = $provider
      variant = $variant
      time_created = $reader.GetInt64(3)
    }
  }
  finally {
    if ($reader) { $reader.Dispose() }
    $command.Dispose()
  }
}

function Get-ModelFromSession([string] $Json) {
  if (-not $Json) { return $null }
  try { $value = $Json | ConvertFrom-Json } catch { return $null }
  $model = $value.id
  if (-not $model) { $model = $value.modelID }
  if (-not $model) { $model = $value.modelId }
  if (-not $model) { return $null }
  return [pscustomobject]@{
    model = $model
    provider = $value.providerID
    variant = $value.variant
  }
}

if ($PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7 -or [System.Environment]::Version.Major -lt 8) {
  Fail 'PowerShell 7.4 or later (.NET 8+) is required (Microsoft.Data.Sqlite targets .NET 8+).' 1
}

if (-not $Database) {
  $candidates = @()
  if ($env:USERPROFILE) {
    $candidates += Join-Path $env:USERPROFILE '.local\share\opencode\opencode.db'
  }
  if ($HOME) {
    $candidates += Join-Path $HOME '.local/share/opencode/opencode.db'
  }
  $Database = $candidates |
    Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
    Select-Object -First 1
}
if (-not $Database -or -not (Test-Path -LiteralPath $Database -PathType Leaf)) {
  Fail 'OpenCode database not found. Pass -Database <path>.' 1
}

if (-not $SessionId) {
  Fail 'OPENCODE_SESSION_ID is not set. Pass -SessionId <id>.' 1
}

$assemblies = Get-SqliteAssemblies -Root $SqliteRoot
if (-not $assemblies) {
  Fail -Message 'Microsoft.Data.Sqlite was not found.' -Code 1 -Detail $InstallHint
}

try {
  Initialize-Sqlite -Assemblies $assemblies
}
catch {
  Fail "Could not load Microsoft.Data.Sqlite: $($_.Exception.Message)" 1
}

$builder = [Microsoft.Data.Sqlite.SqliteConnectionStringBuilder]::new()
$builder.DataSource = $Database
$builder.Mode = [Microsoft.Data.Sqlite.SqliteOpenMode]::ReadOnly
$connection = [Microsoft.Data.Sqlite.SqliteConnection]::new($builder.ConnectionString)

try {
  $connection.Open()

  $session = Get-SessionRecord -Connection $connection -SessionId $SessionId
  if (-not $session) { Fail "Session not found: $SessionId" 1 }

  $assistant = Get-MessageModel -Connection $connection -SessionId $SessionId -Type 'assistant'
  $switched = Get-MessageModel -Connection $connection -SessionId $SessionId -Type 'model-switched'

  if ($assistant -and $assistant.model) {
    $model = $assistant.model
    $provider = $assistant.provider
    $variant = $assistant.variant
    $source = 'latest-assistant'
    $confidence = 'exact'
    $resolvedAt = $assistant.time_created
  }
  elseif ($switched -and $switched.model) {
    $model = $switched.model
    $provider = $switched.provider
    $variant = $switched.variant
    $source = 'latest-model-switch'
    $confidence = 'exact'
    $resolvedAt = $switched.time_created
  }
  else {
    $fallback = Get-ModelFromSession $session.model
    if (-not $fallback) { Fail "No model recorded for session: $SessionId" 3 }
    $model = $fallback.model
    $provider = $fallback.provider
    $variant = $fallback.variant
    $source = 'session-default'
    $confidence = 'session-default'
    $resolvedAt = $session.time_created
  }

  $modelShort = if ($model.Contains('/')) { $model.Substring($model.LastIndexOf('/') + 1) } else { $model }
  $reportedModel = if ($ShortModelName -and $modelShort) { $modelShort } else { $model }

  $result = [ordered]@{
    sessionId = $SessionId
    sessionTitle = $session.title
    sessionCreatedAt = ConvertTo-IsoDate $session.time_created
    sessionUpdatedAt = ConvertTo-IsoDate $session.time_updated
    model = $model
    modelShort = $modelShort
    reportedModel = $reportedModel
    provider = $provider
    variant = $variant
    modelSource = $source
    confidence = $confidence
    modelResolvedAt = ConvertTo-IsoDate $resolvedAt
  }
}
catch [Microsoft.Data.Sqlite.SqliteException] {
  Fail "SQLite error: $($_.Exception.Message)" 1
}
catch {
  Fail "SQLite query failed: $($_.Exception.Message)" 1
}
finally {
  $connection.Dispose()
}

if ($Json) {
  $result | ConvertTo-Json -Depth 6
  exit 0
}

Write-Output "model: $($result.reportedModel)"
exit 0
