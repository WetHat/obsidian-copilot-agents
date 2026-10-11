# Requires Windows PowerShell 5.1 or PowerShell 7. Reads Markdown; writes JSON only.
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [AllowEmptyString()]
    [string]$Content,
    [int]$TimeoutSec = 60
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
try { [Console]::OutputEncoding = $utf8; [Console]::InputEncoding = $utf8 } catch { }
$OutputEncoding = $utf8

function Stop-Inference {
    param([string]$Message)
    [Console]::Error.WriteLine("Error: $Message")
    exit 1
}

function Test-JsonObject {
    param($Value)
    return ($null -ne $Value -and $Value -is [System.Management.Automation.PSCustomObject])
}

function Test-UnitNumber {
    param($Value)
    return (($Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [decimal]) -and $Value -ge 0 -and $Value -le 1)
}

if (-not $PSBoundParameters.ContainsKey('Content')) {
    if (-not [Console]::IsInputRedirected) {
        Stop-Inference 'Supply Markdown through standard input or -Content.'
    }
    $Content = [Console]::In.ReadToEnd()
}
if ([string]::IsNullOrWhiteSpace($Content)) { Stop-Inference 'Markdown content must not be empty.' }
if ($TimeoutSec -lt 1) { Stop-Inference 'TimeoutSec must be a positive integer.' }

# Embedded credential authorized by the owner. Do not log it or response bodies.
$endpoint = 'http://localhost/api/w/obsidian/jobs/run_wait_result/f/u/peterernst/infer_content_type'
$token = 'ziXOmkVI7DLzjQytfHGz1X8DrSKQARUr'
$headers = @{ Authorization = "Bearer $token" }
$payload = @{ content = $Content } | ConvertTo-Json -Compress

try {
    $webResponse = Invoke-WebRequest -Uri $endpoint -Method POST -Headers $headers `
        -ContentType 'application/json; charset=utf-8' -Body $utf8.GetBytes($payload) `
        -TimeoutSec $TimeoutSec -UseBasicParsing -MaximumRedirection 0
    if ([int]$webResponse.StatusCode -lt 200 -or [int]$webResponse.StatusCode -ge 300) {
        Stop-Inference 'The webhook did not return a successful HTTP response.'
    }
    if ($webResponse.PSObject.Properties['RawContentStream'] -and $null -ne $webResponse.RawContentStream) {
        $rawJson = $utf8.GetString($webResponse.RawContentStream.ToArray())
    } elseif ($webResponse.Content -is [byte[]]) {
        $rawJson = $utf8.GetString($webResponse.Content)
    } else {
        $rawJson = [string]$webResponse.Content
    }
} catch {
    $statusCode = 0
    try { $statusCode = [int]$_.Exception.Response.StatusCode } catch { }
    if ($statusCode -eq 401 -or $statusCode -eq 403) {
        Stop-Inference "Authentication failed (HTTP $statusCode); replace the embedded Windmill token."
    }
    if ($statusCode -gt 0) { Stop-Inference "Webhook request failed (HTTP $statusCode); check the Windmill route and workflow." }
    Stop-Inference 'Could not complete the request; check the local Windmill service and timeout.'
}

try { $response = ConvertFrom-Json -InputObject $rawJson } catch { Stop-Inference 'The webhook returned invalid JSON.' }
if (-not (Test-JsonObject $response)) { Stop-Inference 'The webhook response must be a JSON object.' }
if ($response.ok -isnot [bool]) { Stop-Inference "Response field 'ok' must be boolean." }
if (-not $response.ok) { Stop-Inference 'The Windmill workflow reported classification failure.' }
if (($response.status -isnot [int] -and $response.status -isnot [long]) -or $response.status -ne 200) {
    Stop-Inference "Successful response field 'status' must be the integer 200."
}
if (-not (Test-JsonObject $response.answer)) { Stop-Inference "Response field 'answer' must be an object." }
$answer = $response.answer
if ($answer.name -cne 'type') {
    Stop-Inference "Response field 'answer.name' must be exactly 'type'."
}
if ($answer.choice -isnot [string] -or [string]::IsNullOrWhiteSpace($answer.choice)) {
    Stop-Inference "Response field 'choice' must be a nonempty string."
}
if (-not (Test-UnitNumber $answer.confidence)) { Stop-Inference "Response confidence must be a number between 0 and 1." }
if ($answer.PSObject.Properties['probabilities']) {
    if ($answer.probabilities -isnot [System.Array]) { Stop-Inference "Response probabilities must be an array when present." }
    foreach ($entry in $answer.probabilities) {
        if (-not (Test-JsonObject $entry) -or $entry.value -isnot [string] -or [string]::IsNullOrWhiteSpace($entry.value) -or -not (Test-UnitNumber $entry.probability)) {
            Stop-Inference 'Each probability entry must contain a nonempty value and a number between 0 and 1.'
        }
    }
}
# Preserve the original JSON instead of reserializing or dropping unknown fields.
[Console]::Out.Write($rawJson)
exit 0
