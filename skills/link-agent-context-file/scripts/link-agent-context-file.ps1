<#
.SYNOPSIS
  Formats a wikilink to an agent context file with its parent folder as alias.
.DESCRIPTION
  Accepts a vault-relative path to AGENTS.md, SKILL.md, or CLAUDE.md, a
  vault-relative path to a folder holding one of them, or that folder's bare
  name. Prints exactly one line: [[<link path>|<folder name>]]
  Exits 1 with a message on stderr when the target cannot be resolved.
.PARAMETER Target
  Vault-relative path or bare folder name to link.
.PARAMETER VaultRoot
  Vault root used to resolve Target. Defaults to four levels above this script
  (scripts/ -> skill folder -> skills/ -> copilot/ -> vault root).
#>
param(
  [Parameter(Position = 0)]
  [string] $Target,
  [string] $VaultRoot
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Precedence order: AGENTS.md wins over SKILL.md, which wins over CLAUDE.md.
$ContextFileNames = @('AGENTS.md', 'SKILL.md', 'CLAUDE.md')
$Usage = 'Usage: link-agent-context-file.ps1 <vault-path-or-folder-name> [-VaultRoot <vault-root>]'

function Fail([string] $Message) {
  [Console]::Error.WriteLine("link-agent-context-file: $Message")
  exit 1
}

# Returns the highest-precedence context file in $Directory, or $null.
function Get-ContextFile([string] $Directory) {
  $items = @(Get-ChildItem -LiteralPath $Directory -File -Force -ErrorAction SilentlyContinue)
  foreach ($name in $ContextFileNames) {
    foreach ($item in $items) {
      if ($item.Name -ieq $name) { return $item }
    }
  }
  return $null
}

# Returns $Path relative to $Base with forward slashes, or $Path when unrelated.
function Get-RelativePath([string] $Base, [string] $Path) {
  $b = $Base.TrimEnd([char[]]@('\', '/'))
  if ($Path.StartsWith($b, [StringComparison]::OrdinalIgnoreCase)) {
    return (($Path.Substring($b.Length).TrimStart([char[]]@('\', '/')) -replace '\\', '/'))
  }
  return ($Path -replace '\\', '/')
}

if ([string]::IsNullOrWhiteSpace($Target)) {
  [Console]::Error.WriteLine($Usage)
  exit 1
}

# Accept a bare path or a pasted wikilink; drop any alias inside it.
$rel = $Target.Trim()
if ($rel -match '^\[\[([^\]\|]+)(\|[^\]]*)?\]\]$') { $rel = $Matches[1] }
$rel = ($rel -replace '\\', '/') -replace '/{2,}', '/'
$rel = ($rel -replace '^(\./)+', '').Trim().Trim([char[]]@('/'))

if (-not $rel) {
  [Console]::Error.WriteLine($Usage)
  exit 1
}
if ($rel -match '^[A-Za-z]:' -or $rel.StartsWith('//')) {
  Fail "'$rel' is an absolute path. Pass a path relative to the vault root."
}

$segments = @($rel -split '/')
if ($segments -contains '..') {
  Fail "'$rel' must stay inside the vault; '..' segments are not allowed."
}

$root = if ($VaultRoot) {
  $VaultRoot
} else {
  Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
}
$root = $root.Trim().TrimEnd([char[]]@('\', '/'))
if (-not (Test-Path -LiteralPath $root -PathType Container)) {
  Fail "vault root '$root' is not a directory. Pass -VaultRoot <vault-root>."
}
$root = (Resolve-Path -LiteralPath $root).ProviderPath.TrimEnd([char[]]@('\', '/'))

$leaf = $segments[$segments.Count - 1]
$isFileForm = $false
foreach ($name in $ContextFileNames) {
  # Match both 'AGENTS.md' and the extension-less 'AGENTS'.
  if ($leaf -ieq $name -or $leaf -ieq [IO.Path]::GetFileNameWithoutExtension($name)) {
    $isFileForm = $true
  }
}

if ($isFileForm) {
  # Accept the name with or without .md; always resolve the .md file on disk.
  $fileName = if ([IO.Path]::GetExtension($leaf)) { $leaf } else { "$leaf.md" }
  $dirSegments = if ($segments.Count -ge 2) { $segments[0..($segments.Count - 2)] } else { @() }
  $full = Join-Path $root (@($dirSegments + $fileName) -join [IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
    Fail "no file at '$rel' under vault root '$root'. Pass the full vault-relative path (for example 'copilot/projects/Skill Auditor/AGENTS'), or -VaultRoot if that root is wrong."
  }
  $item = Get-Item -LiteralPath $full
  $stem = [IO.Path]::GetFileNameWithoutExtension($item.Name)
  $linkPath = if ($dirSegments.Count -ge 1) {
    (($dirSegments -join '/') + '/' + $stem)
  } else {
    $stem
  }
  $folderName = $item.Directory.Name
}
elseif ($rel.Contains('/')) {
  $full = Join-Path $root ($segments -join [IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path -LiteralPath $full -PathType Container)) {
    if ([IO.Path]::GetExtension($leaf)) {
      Fail "'$leaf' is not an agent context file; expected AGENTS.md, SKILL.md, or CLAUDE.md."
    }
    Fail "no folder at '$rel' under vault root '$root'. Pass -VaultRoot if that root is wrong."
  }
  $file = Get-ContextFile $full
  if (-not $file) {
    Fail "no agent context file (AGENTS.md, SKILL.md, or CLAUDE.md) in '$rel'."
  }
  $linkPath = "$rel/$([IO.Path]::GetFileNameWithoutExtension($file.Name))"
  $folderName = (Get-Item -LiteralPath $full).Name
}
else {
  # Short form: find folders of that name anywhere in the vault, skipping
  # dot-folders (.git, .obsidian, .opencode, .agents, .trash) and links.
  $found = @()
  $stack = New-Object System.Collections.Stack
  $stack.Push($root)
  while ($stack.Count -gt 0) {
    $current = [string]$stack.Pop()
    $children = @(Get-ChildItem -LiteralPath $current -Directory -Force -ErrorAction SilentlyContinue)
    foreach ($child in $children) {
      if ($child.Name.StartsWith('.')) { continue }
      # Skip symlinks and junctions to avoid loops. Do not test the reparse-point
      # attribute: OneDrive marks ordinary synced folders with it.
      if ($child.LinkType) { continue }
      if ($child.Name -ieq $rel) { $found += $child }
      $stack.Push($child.FullName)
    }
  }

  $resolved = @()
  foreach ($dir in $found) {
    $file = Get-ContextFile $dir.FullName
    if ($file) { $resolved += [pscustomobject]@{ Dir = $dir; File = $file } }
  }

  if ($resolved.Count -eq 0) {
    if ($found.Count -eq 0) {
      Fail "no folder named '$rel' in vault '$root'. Pass the vault-relative path instead."
    }
    if ($found.Count -eq 1) {
      Fail "folder '$(Get-RelativePath $root $found[0].FullName)' holds no agent context file (AGENTS.md, SKILL.md, or CLAUDE.md)."
    }
    $list = ($found | ForEach-Object { Get-RelativePath $root $_.FullName }) -join "', '"
    Fail "'$rel' matches $($found.Count) folders but none holds AGENTS.md, SKILL.md, or CLAUDE.md: '$list'."
  }
  if ($resolved.Count -gt 1) {
    $list = ($resolved | ForEach-Object { Get-RelativePath $root $_.Dir.FullName }) -join "', '"
    Fail "'$rel' matches several folders: '$list'. Pass one of those vault-relative paths instead."
  }

  $linkPath = "$($resolved[0].Dir.Name)/$([IO.Path]::GetFileNameWithoutExtension($resolved[0].File.Name))"
  $folderName = $resolved[0].Dir.Name
}

if (-not $folderName) {
  Fail "could not determine the folder name for '$rel'."
}

[Console]::Out.WriteLine("[[$linkPath|$folderName]]")
exit 0
