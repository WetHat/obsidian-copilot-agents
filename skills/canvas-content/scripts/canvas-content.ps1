#Requires -Version 5.1
<#
.SYNOPSIS
  Resolve an Obsidian Canvas (.canvas) into a semantic Markdown report.

.DESCRIPTION
  All algorithmic work for the canvas-content skill lives here; the launchers
  resolve the user's target and pipe the canvas JSON into this worker.

  Reads one message, in order of precedence:
      1. -Path <file> argument -> that .canvas file is read (the launchers
         forward the user's target this way);
      2. pipeline input (JSON string, @{ Path = ... } hashtable, or a canvas
         object), collected into one message when several items arrive;
      3. raw bytes redirected to stdin, decoded with a UTF-8/16 BOM honoured.

  Emits the report on stdout; the final line is the report itself (one line
  'Unresolved: <reason>' on bad input, with the reason detailed on stderr
  and a non-zero exit code).

.PARAMETER Path
    Path to the .canvas file to resolve. The value 'Raw' means: read the canvas
    JSON from stdin bytes.

.PARAMETER MaxText
    0 (default) never truncates. When greater than 0, each text card is reduced
    to its first <MaxText> sentences, the structure and every card are kept,
    and the report ends with 'Truncated: <n> cards shortened.' when at least
    one card was shortened. The skill passes 2 or 3 for canvases that exceed
    the context window.

.EXAMPLE
    pwsh canvas-content.ps1 'vault/Board.canvas'

.EXAMPLE
    pwsh canvas-content.ps1 -Path 'vault/Board.canvas' -MaxText 3

.EXAMPLE
      Get-Content -Raw 'vault/Board.canvas' | pwsh canvas-content.ps1
      cmd /c "type vault/Board.canvas | pwsh canvas-content.ps1 -Path Raw"
  #>
  # Intentionally a non-advanced script: no [Parameter(...)] attributes and no
  # begin/process/end blocks. Piped lines arrive in $input; parameters bind by
  # position and name.
  param(
      [string] $Path,
      [int] $MaxText = 0
  )

  $ErrorActionPreference = 'Stop'
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $OutputEncoding = [System.Text.Encoding]::UTF8

  $sb = New-Object System.Text.StringBuilder
  function Append([string] $Text) { [void] $sb.AppendLine($Text) }
  function Fail([string] $Message, [string] $Reason) {
      [Console]::Error.WriteLine("canvas-content: $Message")
      [Console]::Out.WriteLine("Unresolved: $Reason")
      exit 1
  }

function Num([object] $Value) {
    if ($null -eq $Value) { return 0.0 }
    $d = 0.0
    if ([double]::TryParse([string] $Value, [ref] $d)) { return $d }
    return 0.0
}

function Split-Lines([string] $Text) {
    return @([regex]::Split($Text, "\r\n|\n|\r"))
}

function Get-StringList([object] $Value) {
    if ($null -eq $Value) { return $null }
    if ($Value -is [string]) { return $null }   # a scalar stays a scalar
    if ($Value -is [System.Collections.IList]) {
        $out = @()
        foreach ($x in $Value) { $out += [string] $x }
        # The unary comma keeps an empty list an empty list: a bare '@()'
        # return unrolls to $null at the call site, and the value then falls
        # through to the scalar path as ''.
        return ,$out
    }
    return $null
}

# ---------------------------------------------------------------------------
# metadata.frontmatter -> YAML
#   Emitted verbatim, key order unchanged: arrays as flow sequences
#   ('[a, b, c]'), objects nested with two spaces. A scalar is quoted only when
#   YAML would otherwise change its type (booleans, numbers, null, dates) or
#   fail to parse (': ', ' #', leading indicators, and — inside a flow sequence
#   — a comma, a bracket, or a colon). 'version' is format plumbing: never
#   emitted.
# ---------------------------------------------------------------------------
$yamlBoolRe = '^(y|Y|n|N|yes|Yes|YES|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$'
$yamlNullRe = '^(null|Null|NULL|~)$'
$yamlDateRe = '^\d{4}-\d{1,2}-\d{1,2}$'
$yamlNumberRe = '^[-+]?(([0-9]*\.[0-9]+)|([0-9]+(\.[0-9]*)?))([eE][-+]?[0-9]+)?$'
$yamlTimeRe = '^[0-9]{1,2}:[0-9]{1,2}(:[0-9]{1,2}(\.[0-9]+)?)?[ \t]*$'

function Get-NumberText([object] $Value) {
    # JSON numbers (int/double/decimal) stay numeric YAML scalars; invariant
    # formatting keeps '1.5' from becoming '1,5' on comma-decimal locales.
    if ($Value -is [double] -or $Value -is [single] -or $Value -is [decimal]) {
        return ([string] ([double] $Value).ToString([Globalization.CultureInfo]::InvariantCulture))
    }
    return [string] $Value
}

function Test-YamlTransform([string] $Candidate) {
    if ($Candidate -match ':(\s|$)') { return $true }
    if ($Candidate -match '(\s\#|^\#)') { return $true }
    if ($Candidate.Trim() -eq '') { return $true }
    if ($Candidate -match $yamlBoolRe) { return $true }
    if ($Candidate -match $yamlNullRe) { return $true }
    if ($Candidate -match $yamlDateRe) { return $true }
    if ($Candidate -match $yamlNumberRe) { return $true }
    if ($Candidate -match '^[-+]?\.(inf|Inf|INF|nan|NaN|NAN)$') { return $true }
    if ($Candidate -match $yamlTimeRe) { return $true }
    $first = $Candidate[0]
    if (@('-', '?', ':', '{', '}', '[', ']', '&', '*', '#', '!', '|', '>', "'", '"', '%', '@', '`') -contains $first) { return $true }
    return $false
}

function Get-DoubleQuoted([string] $Value) {
    return '"' + (($Value -replace '\\', '\\' -replace '"', '\"')) + '"'
}

function New-YamlScalar([string] $Value, [int] $Indent) {
    if ([string]::IsNullOrEmpty($Value)) { return "''" }
    if ($Value -match '\r|\n') {
        # Block literal: content lines indented (Indent+2), trailing blank
        # lines dropped (the final newline is implicit).
        $body = $Value -replace '\r\n', "`n"
        $body = $body -replace '\r', "`n"
        $lines = @($body -split "`n")
        # Trailing blank lines are dropped; stop at one element, because
        # '$lines[0..-1]' re-yields that same element and would never shrink.
        while ($lines.Count -gt 1 -and $lines[$lines.Count - 1].Trim() -eq '') {
            $lines = @($lines[0..($lines.Count - 2)])
        }
        if ($lines.Count -eq 0 -or ($lines.Count -eq 1 -and $lines[0].Trim() -eq '')) { return "''" }
        $pad = ' ' * (2 + $Indent)
        $block = ($lines | ForEach-Object { $pad + $_ }) -join "`n"
        return ("|-" + "`n" + $block)
    }
    if (-not (Test-YamlTransform $Value)) { return $Value }
    if ($Value -match $yamlBoolRe -or $Value -match $yamlNullRe) {
        # Quoted null / quoted boolean collapse on YAML 1.1 parsers; the
        # double-quoted form always round-trips.
        return Get-DoubleQuoted $Value
    }
    return "'" + ($Value -replace "'", "''") + "'"
}

# A plain scalar inside a flow sequence ends at a comma or a bracket, and a
# bare ':' can read as a mapping, so those need quoting even though the same
# text is safe in a block context.
$yamlFlowBreakers = '[,:\[\]\{\}]'

function Test-YamlFlowTransform([string] $Candidate) {
    if (Test-YamlTransform $Candidate) { return $true }
    if ($Candidate -match $yamlFlowBreakers) { return $true }
    if ($Candidate -ne $Candidate.Trim()) { return $true }   # spaces are folded away
    return $false
}

function New-YamlFlowScalar([string] $Value) {
    # One item of a flow sequence ('[a, b, c]'). A block literal is not valid
    # in flow context, so a multi-line value becomes an escaped double-quoted
    # scalar instead of '|-' with indented lines.
    if ([string]::IsNullOrEmpty($Value)) { return "''" }
    if ($Value -match '\r|\n') {
        $escaped = $Value -replace '\\', '\\' -replace '"', '\"'
        $escaped = $escaped -replace "`r`n", '\n' -replace "`r", '\n' -replace "`n", '\n'
        return '"' + $escaped + '"'
    }
    if (-not (Test-YamlFlowTransform $Value)) { return $Value }
    if ($Value -match $yamlBoolRe -or $Value -match $yamlNullRe) { return Get-DoubleQuoted $Value }
    return "'" + ($Value -replace "'", "''") + "'"
}

function New-YamlFlowList([object[]] $Items) {
    # '[a, b, c]'; the caller appends it after '<key>: '.
    $parts = @()
    foreach ($s in $Items) { $parts += (New-YamlFlowScalar ([string] $s)) }
    return '[' + ($parts -join ', ') + ']'
}

function New-Frontmatter([object] $Frontmatter) {
    # Serialises the frontmatter object as a YAML flow-level mapping.
    if ($null -eq $Frontmatter) { return @() }
    $out = @()
    if ($Frontmatter -is [System.Management.Automation.PSCustomObject]) {
        $out += '---'
        foreach ($p in $Frontmatter.PSObject.Properties) {
            $name = [string] $p.Name
            if ($name -ieq 'version') { continue }
            if ($p.Value -is [PSCustomObject]) {
                $sub = @(New-FrontmatterKeys $p.Value)
                        if ($sub.Count -eq 0) { $out += "$($name): {}"; continue }
                        $out += "$($name):"
                foreach ($kv in $sub) { $out += $kv }
                continue
            }
            $list = Get-StringList $p.Value
            if ($null -ne $list) {
                if ($list.Count -eq 0) { $out += "$($name): []"; continue }
                $out += "$($name): " + (New-YamlFlowList $list)
                continue
            }
                    if ($null -eq $p.Value) { $out += "$($name): null"; continue }
                    if ($p.Value -is [bool]) { $out += "$($name): " + $(if ([bool] $p.Value) { 'true' } else { 'false' }); continue }
                    if ($p.Value -is [int] -or $p.Value -is [long] -or $p.Value -is [double] -or $p.Value -is [single] -or $p.Value -is [decimal]) {
                        $out += "$($name): " + (Get-NumberText $p.Value); continue
                    }
                    $out += "$($name): " + (New-YamlScalar ([string] $p.Value) 0)
                }
        # An empty frontmatter object must emit nothing; a bare '---' pair
        # would read as an empty YAML document at the top of the report.
        if ($out.Count -gt 1) { $out += '---' } else { $out = @() }
    }
    elseif ($Frontmatter -is [string]) {
        # Pre-serialised frontmatter: emit verbatim.
        $text = [string] $Frontmatter
        $text = $text.Trim()
        if ($text -ne '') {
            $out += '---'
            $out += @($text -split "\r?\n")
            $out += '---'
        }
    }
    return $out
}

function New-FrontmatterKeys([object] $Obj) {
    $out = @()
    foreach ($p in $Obj.PSObject.Properties) {
        $name = [string] $p.Name
        if ($name -ieq 'version') { continue }
        if ($p.Value -is [PSCustomObject]) {
            $sub = @(New-FrontmatterKeys $p.Value)
            if ($sub.Count -eq 0) { $out += "  ${name}: {}"; continue }
            $out += "  ${name}:"
                    foreach ($kv in $sub) { $out += '  ' + $kv }
            continue
        }
        $list = Get-StringList $p.Value
        if ($null -ne $list) {
            if ($list.Count -eq 0) { $out += "  ${name}: []"; continue }
            $out += "  ${name}: " + (New-YamlFlowList $list)
            continue
        }
        if ($null -eq $p.Value) { $out += "  ${name}: null"; continue }
        if ($p.Value -is [bool]) { $out += "  ${name}: " + $(if ([bool] $p.Value) { 'true' } else { 'false' }); continue }
                if ($p.Value -is [int] -or $p.Value -is [long] -or $p.Value -is [double] -or $p.Value -is [single] -or $p.Value -is [decimal]) {
                    $out += "  ${name}: " + (Get-NumberText $p.Value); continue
                }
                $out += "  ${name}: " + (New-YamlScalar ([string] $p.Value) 2)
            }
    return $out
}

# ---------------------------------------------------------------------------
# Text card normalisation
#   Fenced code blocks (``` or ~~~) are opaque: none of the rewrites below
#   apply inside a fence.
# ---------------------------------------------------------------------------
function Test-FenceMarker([string] $Line) {
    return ($Line.TrimStart().StartsWith('```') -or $Line.TrimStart().StartsWith('~~~'))
}

function Get-NormalizedCardText([string] $Text) {
    if ($null -eq $Text) { return '' }
    $lines = @(Split-Lines ([string] $Text))
    if ($lines.Count -eq 0) { return '' }

    # Remove a leading YAML frontmatter block (--- ... ---): it holds
    # decoration classes such as cssclasses, not content.
    if ($lines[0].Trim() -eq '---') {
        $endIdx = -1
        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq '---') { $endIdx = $i; break }
        }
        if ($endIdx -ge 0) {
            $rest = @()
            for ($i = $endIdx + 1; $i -lt $lines.Count; $i++) { $rest += $lines[$i] }
            $lines = $rest
            # Drop leading blank lines. The loop must stop at one element:
            # '$lines[1..0]' re-yields that same element, so a card holding
            # nothing but blank lines after its frontmatter would spin forever.
            while ($lines.Count -gt 1 -and $lines[0].Trim() -eq '') {
                $lines = @($lines[1..($lines.Count - 1)])
            }
            if ($lines.Count -eq 1 -and $lines[0].Trim() -eq '') { $lines = @() }
        }
    }
    if ($lines.Count -eq 0) { return '' }

    # Find the card's shallowest heading level (fences are opaque).
    $fenced = $false
    $minLevel = 0
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if (Test-FenceMarker $line) { $fenced = -not $fenced; continue }
        if (-not $fenced -and $line -match '^(#{1,6})\s+\S') {
            $h = $Matches[1].Length
            if ($minLevel -eq 0 -or $h -lt $minLevel) { $minLevel = $h }
        }
    }
    $offset = 0
    if ($minLevel -gt 0 -and $minLevel -lt 3) { $offset = 3 - $minLevel }

    # Single fence-aware rewrite pass: callouts, empty layout HTML, heading
    # demotion, thematic breaks; trim trailing whitespace outside fences.
    $fenced = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if (Test-FenceMarker $line) {
            $fenced = -not $fenced
            continue
        }
        if ($fenced) { continue }
        if ($line -match '^\s*(?:>\s*)+') {
                    $newLine = [regex]::Replace($line, '\[![A-Za-z0-9_-]+\]', '')
                    $newLine = [regex]::Replace($newLine, '^(\s*(?:>\s*)+)\s*[+-]\s*(?=\S)', '$1')
                    $m = [regex]::Match($newLine, '^(\s*)((?:>\s*)+)(.*)$')
                    if ($m.Success) {
                        # one space after each '>' marker and nowhere else; the
                        # nesting depth survives ("> > inner" stays "> > inner")
                        $markers = ([regex]::Matches($m.Groups[2].Value, '>')).Count
                        $quote = if ($markers -gt 0) { ('> ' * $markers) } else { '' }
                        $rest = $m.Groups[3].Value.TrimStart()
                        $line = $m.Groups[1].Value + ($quote + $rest).TrimEnd()
                    }
                }
        elseif ($line -match '(?i)^<(div|span|p|section|td|tr)\b[^>]*>\s*</\1>$') {
            $line = ''   # empty layout element
        }
        elseif ($line -match '(?i)^<(?:br|hr)\s*/?>\s*$') {
            $line = ''   # empty layout break
        }
        elseif ($offset -gt 0 -and $line -match '^(#{1,6})\s+\S') {
            $h = $Matches[1].Length
            $line = $line -replace '^#{1,6}', ('#' * ([Math]::Min($h + $offset, 6)))
        }
        elseif ($line.Trim() -eq '---') {
            $line = '***'   # a thematic break must never read as a separator
        }
        $lines[$i] = $line.TrimEnd()
    }

    $joined = [string]::Join("`n", $lines)
    $joined = [regex]::Replace($joined, '[ \t]+(?=\r?\n)', '')
    $joined = [regex]::Replace($joined, '(\r?\n\s*){3,}', "`n`n")
    return $joined.Trim()
}

# ---------------------------------------------------------------------------
# Sentence-level truncation and card labels
# ---------------------------------------------------------------------------
function Get-SentenceMarks([string] $Text) {
    # End offsets of sentence terminators: '.', '!', '?' (runs collapsed to
    # one mark) when followed by whitespace or end; a '.' between digits is
    # not a terminator.
    $marks = New-Object System.Collections.Generic.List[int]
    $i = 0
    while ($i -lt $Text.Length) {
        $c = $Text[$i]
        if ($c -eq '.') {
            $prevDigit = ($i -gt 0 -and $Text[$i - 1] -match '[0-9]')
            $nextDigit = ($i + 1 -lt $Text.Length -and $Text[$i + 1] -match '[0-9]')
            if (-not ($prevDigit -and $nextDigit)) {
                $j = $i
                while ($j + 1 -lt $Text.Length -and $Text[$j + 1] -eq '.') { $j++ }
                if ($j + 1 -ge $Text.Length) { $marks.Add($j) }
                elseif ($Text[$j + 1] -match '\s') { $marks.Add($j) }
                $i = $j + 1
                continue
            }
        }
        if ($c -eq '!' -or $c -eq '?') {
            $j = $i
            while ($j + 1 -lt $Text.Length -and $Text[$j + 1] -eq $c) { $j++ }
            if ($j + 1 -ge $Text.Length) { $marks.Add($j) }
            elseif ($Text[$j + 1] -match '\s') { $marks.Add($j) }
            $i = $j + 1
            continue
        }
        $i++
    }
    return @($marks)
}

function Get-FirstSentences([string] $Text, [int] $Count) {
    if ($Count -le 0 -or $Text.Length -eq 0) { return $Text }
    $marks = @(Get-SentenceMarks $Text)
    if ($marks.Count -le $Count) { return $Text }
    $cut = $marks[$Count - 1] + 1
    return $Text.Substring(0, $cut).TrimEnd()
}

function Get-CardLabel([string] $Body) {
    # First non-empty line of the rendered card, stripped of '>' depth,
    # heading hashes, list markers, emphasis, and inline code. A single
    # wikilink / Markdown link uses its alias, link text, or target basename.
    # Otherwise cut at the first ': ', ' - ', en/em dash, or '. ' inside the
    # first 40 characters, else truncate to 40 characters at a word boundary
    # with '...'.
    $first = $null
    foreach ($line in (Split-Lines $Body)) {
        if ($line.Trim() -eq '') { continue }
        $first = $line
        break
    }
    if ($null -eq $first) { return '' }
    $v = $first.Trim()

    if ($v -match '^\[\[([^\]\|]+)(\|([^\]]+))?\]\]\s*$') {
        if ($Matches[3] -and $Matches[3].Trim() -ne '') { return $Matches[3].Trim() }
        $target = $Matches[1].Trim()
        $target = $target -replace '#.*$', '' -replace '\^.*$', ''
        $base = [IO.Path]::GetFileName($target)
        if ($base -match '^(.*)\.(md|canvas)$') { $base = $Matches[1] }
        return $base
    }
    if ($v -match '^\[([^\]]*)\]\(([^)]*)\)\s*$') {
        if ($Matches[1].Trim() -ne '') { return $Matches[1].Trim() }
        $hub = $Matches[2]
        $hub = $hub -replace '^[a-z][a-z0-9+.-]*://', ''
        $hub = $hub -replace '/+$', ''
        return [IO.Path]::GetFileName($hub)
    }

    $v = $v -replace '^(>*\s*)+', ''
    $v = $v -replace '^(#{1,6})\s+', ''
    $v = $v -replace '^([-*+]|\d+[.)])\s+', ''
    $v = $v -replace '\*\*([^*]+)\*\*', '$1'
    $v = $v -replace '(?<!\*)\*([^*]+)\*(?!\*)', '$1'
    $v = $v -replace '(?<!_)_([^_]+)_(?!_)', '$1'
    $v = $v -replace [string] [char] 0x2018, "'"
    $v = $v -replace [string] [char] 0x2019, "'"
    $v = $v -replace '~~([^~]+)~~', '$1'
    $v = $v -replace '`([^`]+)`', '$1'

    # Cut at the first ': ', ' - ', en/em dash, or '. ' inside the first 40
        # characters; else truncate to 40 characters at a word boundary.
        $sepEn = [string] [char] 0x2013
        $sepEm = [string] [char] 0x2014
        $cutSeps = @(': ', ' - ', (' ' + $sepEn + ' '), (' ' + $sepEm + ' '), '. ')
        if ($v.Length -gt 40) {
            $window = $v.Substring(0, 40)
            $cutAt = -1
            foreach ($sep in $cutSeps) {
                $pos = $window.IndexOf($sep)
                if ($pos -ge 0 -and ($cutAt -lt 0 -or $pos -lt $cutAt)) { $cutAt = $pos }
            }
            if ($cutAt -ge 0) {
                $v = $v.Substring(0, $cutAt).TrimEnd()
            } else {
                $space = $window.LastIndexOf(' ')
                $idx = $(if ($space -gt 0) { $space } else { 40 })
                $v = $window.Substring(0, $idx).TrimEnd() + '...'
            }
        } else {
            $cutAt = -1
            foreach ($sep in $cutSeps) {
                $pos = $v.IndexOf($sep)
                if ($pos -ge 0 -and ($cutAt -lt 0 -or $pos -lt $cutAt)) { $cutAt = $pos }
            }
            if ($cutAt -ge 0) { $v = $v.Substring(0, $cutAt).TrimEnd() }
        }
        return $v
    }

function New-CardBody([object] $node) {
    switch ([string] $node.type) {
        'text' {
            $norm = Get-NormalizedCardText ([string] $node.text)
            if ([string]::IsNullOrWhiteSpace($norm)) { return $null }
                    return @{ Body = $norm; Label = (Get-CardLabel $norm); Type = 'text' }
        }
        'file' {
            $file = [string] $node.file
            if ([string]::IsNullOrWhiteSpace($file)) { return $null }
            $link = "[[$file]]"
            $label = [IO.Path]::GetFileName($file)
            if ($label -match '^(.*)\.(md|canvas)$') { $label = $Matches[1] }
            $sub = $node.subpath
            if ($null -ne $sub -and -not [string]::IsNullOrWhiteSpace([string] $sub)) {
                $s = [string] $sub
                if (-not $s.StartsWith('#')) { $s = '#' + $s }
                $link = "[[$file$s]]"
                # The label stays the plain basename: '... #Instructions'
                # wikilinks resolve to the note, whose own title is in the
                # alias position for relation endpoints.
            }
                    return @{ Body = $link; Label = $label; Type = 'file' }
        }
        'link' {
            $url = [string] $node.url
            if ([string]::IsNullOrWhiteSpace($url)) { return $null }
            $labelVal = $node.label
            if ($null -ne $labelVal -and -not [string]::IsNullOrWhiteSpace([string] $labelVal)) {
                $alt = [string] $labelVal
            } else {
                $alt = $url -replace '^[a-z][a-z0-9+.-]*://', ''
                $alt = $alt -replace '/+$', ''
            }
                    return @{ Body = "[$alt]($url)"; Label = $alt; Type = 'link' }
        }
        default { return $null }
    }
}

# ---------------------------------------------------------------------------
# Geometry
# ---------------------------------------------------------------------------
function Get-OverlapRatio([double] $cx, [double] $cy, [double] $cw, [double] $ch,
                          [double] $gx, [double] $gy, [double] $gw, [double] $gh) {
    if ($cw -le 0 -or $ch -le 0) { return 0.0 }
    $ix = [Math]::Max(0.0, [Math]::Min($cx + $cw, $gx + $gw) - [Math]::Max($cx, $gx))
    $iy = [Math]::Max(0.0, [Math]::Min($cy + $ch, $gy + $gh) - [Math]::Max($cy, $gy))
    $intersection = $ix * $iy
    return $intersection / ($cw * $ch)
}

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
$Source = $null
if ($Path) {
    if ($Path -ne 'Raw') {
        $resolved = $Path
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            Fail "no file at '$resolved'" 'file not found'
        }
        try {
            $resolved = (Convert-Path -LiteralPath $resolved)
        } catch {
            # keep the caller's spelling; ReadAllText below reports the error
        }
        $jsonText = [IO.File]::ReadAllText($resolved, [Text.Encoding]::UTF8)
        $SourceName = [IO.Path]::GetFileName($resolved)
        try { $Source = $jsonText | ConvertFrom-Json } catch { Fail "invalid JSON: $($_.Exception.Message)" 'invalid JSON' }
    }
}
if ($null -eq $Source) {
    # $input is a single-pass enumerator: snapshot it exactly once.
    $pipeItems = @($input)
    if ($pipeItems.Count -gt 0) {
        $pipeItems = @($pipeItems | Where-Object { $null -ne $_ })
    }
}
if ($null -eq $Source -and $pipeItems.Count -gt 0) {
        $first = $pipeItems[0]
        if ($first -is [System.Collections.IDictionary]) {
            $converted = New-Object PSCustomObject
            foreach ($k in $first.Keys) {
                Add-Member -InputObject $converted -MemberType NoteProperty -Name ([string] $k) -Value $first[$k]
            }
            $first = $converted
        }
        if ($first -is [string]) {
            # JSON text arrived on the pipeline (e.g. Get-Content -Raw | ...);
            # a JSON string split across lines is re-joined in line order.
            $jsonText = [string]::Join("`n", @($pipeItems | ForEach-Object { [string] $_ }))
            try { $Source = $jsonText | ConvertFrom-Json } catch { Fail "invalid JSON: $($_.Exception.Message)" 'invalid JSON' }
        } else {
            $nodesArr = $first.PSObject.Properties['nodes']
            $pathProp = $first.PSObject.Properties['Path']
            if ($nodesArr -ne $null) {
                $Source = $first
            }             elseif ($pathProp -ne $null -and $null -ne $pathProp.Value) {
                            $pathIn = [string] $pathProp.Value
                            if (-not (Test-Path -LiteralPath $pathIn -PathType Leaf)) { Fail "no file at '$pathIn'" 'file not found' }
                            try {
                                $jsonText = [IO.File]::ReadAllText((Convert-Path -LiteralPath $pathIn), [Text.Encoding]::UTF8)
                            } catch {
                                $jsonText = [IO.File]::ReadAllText((Convert-Path -LiteralPath $pathIn))
                            }
                            $SourceName = [IO.Path]::GetFileName($pathIn)
                            try { $Source = $jsonText | ConvertFrom-Json } catch { Fail "invalid JSON: $($_.Exception.Message)" 'invalid JSON' }
                        }
                    }
            }
            if ($null -eq $Source -and $Path -eq 'Raw') {
    $jsonText = $null
    $bytes = $null
    try {
        if ([Console]::IsInputRedirected) {
            $stdin = [Console]::OpenStandardInput()
            $ms = New-Object System.IO.MemoryStream
            $stdin.CopyTo($ms)
            $bytes = $ms.ToArray()
            $ms.Dispose()
        } else {
            $bytes = @()
        }
    } catch {
        $bytes = @()
    }
    if ($null -eq $bytes -or $bytes.Length -eq 0) {
        Fail 'no stdin input; pass the canvas JSON' 'no input'
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $jsonText = [Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $jsonText = [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        $jsonText = [Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
    } else {
        $jsonText = [Text.Encoding]::UTF8.GetString($bytes)
    }
    if ([string]::IsNullOrWhiteSpace($jsonText)) { Fail 'input is empty or not text' 'empty input' }
    try { $Source = $jsonText | ConvertFrom-Json } catch { Fail "invalid JSON: $($_.Exception.Message)" 'invalid JSON' }
}

if ($null -eq $Source) { Fail 'no input; pass -Path, pipeline input, or -Path Raw with stdin' 'no input' }
if ($null -eq $Source.PSObject.Properties['nodes']) { Fail "no 'nodes' array in the JSON value" 'no nodes array' }
$nodes = New-Object System.Collections.Generic.List[object]
if ($null -ne $Source.nodes) {
    foreach ($n in @($Source.nodes)) { if ($null -ne $n) { $nodes.Add($n) } }
}

# ---------------------------------------------------------------------------
# Build the report
# ---------------------------------------------------------------------------
$FmLines = New-Object System.Collections.Generic.List[string]
$metaProp = $Source.PSObject.Properties['metadata']
if ($null -ne $metaProp -and $null -ne $metaProp.Value -and $metaProp.Value -is [PSCustomObject]) {
    $frontProp = $metaProp.Value.PSObject.Properties['frontmatter']
    $frontmatter = $null
    if ($null -ne $frontProp) { $frontmatter = $frontProp.Value }
    else { $frontmatter = $null }   # metadata without frontmatter emits nothing
    foreach ($l in @(New-Frontmatter $frontmatter)) { $FmLines.Add([string] $l) }
}

$cardTable = New-Object System.Collections.Generic.List[object]
foreach ($node in $nodes) {
    $typeProp = $node.PSObject.Properties['type']
    if ($null -eq $typeProp) { continue }
    $card = New-CardBody $node
    if ($null -eq $card) { continue }
    $entry = [pscustomobject]@{
        Id    = ([string] $node.id)
        Body  = [string] $card.Body
        Label = [string] $card.Label
            Type  = [string] $card.Type
            X     = (Num $node.x)
            Y     = (Num $node.y)
            W     = (Num $node.width)
            H     = (Num $node.height)
        }
    $cardTable.Add($entry)
}

# Groups, in node-array order (Obsidian writes children after their parent,
# which is the depth-first order; siblings are re-sorted below by y then x).
$groupTable = New-Object System.Collections.Generic.List[object]
for ($gi = 0; $gi -lt $nodes.Count; $gi++) {
    $node = $nodes[$gi]
    $typeProp = $node.PSObject.Properties['type']
    if ($null -eq $typeProp -or [string] $typeProp.Value -ne 'group') { continue }
    $labelVal = $node.PSObject.Properties['label']
    $labelText = ''
    if ($null -ne $labelVal -and $null -ne $labelVal.Value) { $labelText = ([string] $labelVal.Value).Trim() }
    $g = [pscustomobject]@{
        Id      = ([string] $node.id)
        Label   = $labelText
        X       = (Num $node.x)
        Y       = (Num $node.y)
        W       = (Num $node.width)
        H       = (Num $node.height)
        Index   = $gi
        Parent  = $null
        Children = (New-Object System.Collections.Generic.List[object])
        Position = 0
    }
    $groupTable.Add($g)
}

# Nesting: a group is nested in the smallest strictly larger group that
# contains at least 50% of its area (area-strict to keep the tree acyclic).
for ($gi = 0; $gi -lt $groupTable.Count; $gi++) {
    $g = $groupTable[$gi]
    $best = $null
    for ($pj = 0; $pj -lt $groupTable.Count; $pj++) {
        if ($pj -eq $gi) { continue }
        $parent = $groupTable[$pj]
        if (($parent.W * $parent.H) -le ($g.W * $g.H)) { continue }
        $ratio = Get-OverlapRatio $g.X $g.Y $g.W $g.H $parent.X $parent.Y $parent.W $parent.H
        if ($ratio -lt 0.5) { continue }
        if ($null -eq $best) { $best = $parent }
        else {
            $parentArea = $parent.W * $parent.H
            $bestArea = $best.W * $best.H
            if ($parentArea -lt $bestArea) { $best = $parent }
            elseif ($parentArea -eq $bestArea -and $parent.Index -lt $best.Index) { $best = $parent }
        }
    }
    if ($null -ne $best) {
        $g.Parent = $best
        $best.Children.Add($g)
    }
}

# Group order: depth-first; siblings sort by y then x.
$emitOrder = New-Object System.Collections.Generic.List[object]
function Add-GroupTree([object] $g) {
    $script:emitOrder.Add($g)
    # siblings sort by y, then x
    foreach ($child in @($g.Children | Sort-Object @{ e = 'Y' }, @{ e = 'X' }, @{ e = 'Index' })) { Add-GroupTree $child }
}
$roots = @($groupTable | Where-Object { $null -eq $_.Parent } | Sort-Object @{ e = 'Y' }, @{ e = 'X' }, @{ e = 'Index' })
foreach ($root in $roots) { Add-GroupTree $root }
for ($oi = 0; $oi -lt $emitOrder.Count; $oi++) { $emitOrder[$oi].Position = $oi + 1 }

# Card assignment: join the group with the highest overlap (>= 0.5); ties
# break by smaller group area, then by earlier position in the group order.
$cardGroup = @{}
for ($ci = 0; $ci -lt $cardTable.Count; $ci++) { $cardGroup[$ci] = $null }
for ($ci = 0; $ci -lt $cardTable.Count; $ci++) {
    $card = $cardTable[$ci]
    $best = $null
    $bestRatio = 0.0
    foreach ($g in $groupTable) {
        $ratio = Get-OverlapRatio $card.X $card.Y $card.W $card.H $g.X $g.Y $g.W $g.H
        if ($ratio -lt 0.5) { continue }
        if ($null -eq $best) { $best = $g; $bestRatio = $ratio }
        else {
            if ($ratio -gt $bestRatio) { $best = $g; $bestRatio = $ratio }
            elseif ($ratio -eq $bestRatio) {
                $candArea = $g.W * $g.H
                $bestArea = $best.W * $best.H
                if ($candArea -lt $bestArea) { $best = $g; $bestRatio = $ratio }
                elseif ($candArea -eq $bestArea -and $g.Position -lt $best.Position) { $best = $g; $bestRatio = $ratio }
            }
        }
    }
    $cardGroup[$ci] = $best
}

# ---- emit --------------------------------------------------------------------
foreach ($l in $FmLines) { Append $l }
if ($FmLines.Count -gt 0) { Append '' }

if ($SourceName) {
    $stem = [string] $SourceName
    if ($stem.ToLowerInvariant().EndsWith('.canvas')) { $stem = $stem.Substring(0, $stem.Length - 7) }
    Append "# $stem"
    Append ''
}

$truncate = ($MaxText -gt 0)
$shortened = 0

function Write-Card([object] $card) {
    $body = [string] $card.Body
    if ($truncate -and [string] $card.Type -eq 'text') {
        $cut = Get-FirstSentences $body $MaxText
        if ($cut -ne $body) { $script:shortened++ }
        $body = $cut
    }
    Append $body
    Append ''
}

function Write-CardList([object[]] $cards) {
    $first = $true
    foreach ($c in $cards) {
        if (-not $first) {
            Append ''
            Append '---'
            Append ''
        }
        $first = $false
        Write-Card $c
    }
}

foreach ($g in $emitOrder) {
    $mine = New-Object System.Collections.Generic.List[object]
    for ($ci = 0; $ci -lt $cardTable.Count; $ci++) {
        if ($null -ne $cardGroup[$ci] -and $cardGroup[$ci].Position -eq $g.Position) { $mine.Add($cardTable[$ci]) }
    }
    $sorted = @($mine | Sort-Object @{ e = 'Y' }, @{ e = 'X' })
    $heading = if ([string]::IsNullOrWhiteSpace([string] $g.Label)) { "Group $($g.Position)" } else { [string] $g.Label }
    if ($sorted.Count -eq 0 -and [string]::IsNullOrWhiteSpace([string] $g.Label)) {
        # An unlabelled group with no assigned cards is dropped entirely.
        continue
    }
    Append "## $heading"
    Append ''
    Write-CardList $sorted
}

$ungrouped = New-Object System.Collections.Generic.List[object]
for ($ci = 0; $ci -lt $cardTable.Count; $ci++) {
    if ($null -eq $cardGroup[$ci]) { $ungrouped.Add($cardTable[$ci]) }
}
if ($ungrouped.Count -gt 0) {
    if ($groupTable.Count -gt 0) {
        Append '## Ungrouped'
        Append ''
    }
    Write-CardList @($ungrouped | Sort-Object @{ e = 'Y' }, @{ e = 'X' })
}

# ---- relations ---------------------------------------------------------------
$nodeLookup = @{}
foreach ($node in $nodes) {
    $idProp = $node.PSObject.Properties['id']
    if ($null -ne $idProp -and $null -ne $idProp.Value) { $nodeLookup[[string] $idProp.Value] = $node }
}
$labelById = @{}
foreach ($card in $cardTable) {
    $idKey = [string] $card.Id
    if ($idKey -ne '' -and -not $labelById.ContainsKey($idKey)) { $labelById[$idKey] = [string] $card.Label }
}
foreach ($g in $groupTable) {
    $idKey = [string] $g.Id
    if ($idKey -ne '' -and -not $labelById.ContainsKey($idKey)) {
        $labelById[$idKey] = $(if ([string]::IsNullOrWhiteSpace([string] $g.Label)) { "Group $($g.Position)" } else { [string] $g.Label })
    }
}

function New-RelationLine([string] $From, [string] $To, [string] $FromEnd, [string] $ToEnd, [string] $Label) {
    # '<from> -- (<label>) --> <to>'. The label sits between two dash runs, and
    # a run carries an arrowhead only when that end of the edge is an arrow, so
    # the line shows exactly the directions the canvas draws:
    #   undirected   -- (label) --
    #   from -> to   -- (label) -->
    #   to -> from  <-- (label) --
    #   both ways   <-- (label) -->
    $head = $(if ($FromEnd -eq 'arrow') { '<--' } else { '--' })
    $tail = $(if ($ToEnd -eq 'arrow') { '-->' } else { '--' })
    if ([string]::IsNullOrWhiteSpace($Label)) {
        # No label: the two runs join into one arrow ('--', '-->', '<--', '<-->').
        $joined = ($head -replace '-+$', '') + $tail
        return "$From $joined $To"
    }
    return "$From $head ==$Label== $tail $To"
}

$edgesProp = $Source.PSObject.Properties['edges']
if ($null -ne $edgesProp -and $null -ne $edgesProp.Value) {
    $relLines = New-Object System.Collections.Generic.List[string]
    $relSeen = @{}
    foreach ($edge in @($edgesProp.Value)) {
        if ($null -eq $edge) { continue }
        $fromProp = $edge.PSObject.Properties['fromNode']
        $toProp = $edge.PSObject.Properties['toNode']
        if ($null -eq $fromProp -or $null -eq $toProp) { continue }
        $fromId = [string] $fromProp.Value
        $toId = [string] $toProp.Value
        if (-not $nodeLookup.ContainsKey($fromId) -or -not $nodeLookup.ContainsKey($toId)) { continue }
        $toEnd = 'arrow'
        $fromEnd = 'none'
        $te = $edge.PSObject.Properties['toEnd']
        $fe = $edge.PSObject.Properties['fromEnd']
        if ($null -ne $te -and $null -ne $te.Value) { $toEnd = [string] $te.Value }
        if ($null -ne $fe -and $null -ne $fe.Value) { $fromEnd = [string] $fe.Value }
        $fromLabel = $(if ($labelById.ContainsKey($fromId)) { $labelById[$fromId] } else { $fromId })
        $toLabel = $(if ($labelById.ContainsKey($toId)) { $labelById[$toId] } else { $toId })
        $elabProp = $edge.PSObject.Properties['label']
        $elab = ''
        if ($null -ne $elabProp -and $null -ne $elabProp.Value -and -not [string]::IsNullOrWhiteSpace([string] $elabProp.Value)) {
            $elab = ([string] $elabProp.Value).Trim()
        }
        $line = New-RelationLine $fromLabel $toLabel $fromEnd $toEnd $elab
        if (-not $relSeen.ContainsKey($line)) {
            $relSeen[$line] = $true
            $relLines.Add($line)
        }
    }
    if ($relLines.Count -gt 0) {
        Append '## Relations'
        Append ''
        foreach ($r in $relLines) { Append "- $r" }
    }
}

# ---- finish -------------------------------------------------------------------
$report = $sb.ToString()
$report = $report.TrimEnd()

if ($truncate -and $shortened -gt 0) {
    $report = $report + "`n`nTruncated: $shortened cards shortened."
}

[Console]::Out.Write($report + "`n")
exit 0