# PowerShell script to scrape web page content as Markdown via local Windmill orchestration.
# Targets both Windows PowerShell 5.1 and PowerShell 7+ (cross-platform).
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$Url,

    [Parameter(Position = 1, Mandatory = $false)]
    [ValidateSet("markdown", "json")]
    [string]$Format = "markdown",

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSec = 60
)

# Enforce TLS 1.2 / TLS 1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Configure UTF-8 encoding for standard output and pipeline
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Exit-WithError {
    param(
        [string]$Message,
        [int]$Code = 1
    )
    [Console]::Error.WriteLine($Message)
    exit $Code
}

# Support positional invocation from wrappers or command line
if ([string]::IsNullOrWhiteSpace($Url)) {
    if ($args.Count -gt 0) {
        $Url = $args[0]
        if ($args.Count -gt 1 -and ($args[1] -in "markdown", "json")) {
            $Format = $args[1]
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Url)) {
    Exit-WithError "Usage: scrape-web-content.ps1 [-Url] <url> [-Format <markdown|json>] [-TimeoutSec <seconds>]" 1
}

# Validate URL protocol
if ($Url -notmatch '^https?://') {
    Exit-WithError "Error: Invalid URL format '$Url'. URL must begin with http:// or https://" 1
}

# Resolve endpoint and authentication token from environment or defaults
$endpoint = [Environment]::GetEnvironmentVariable("WINDMILL_URL")
if ([string]::IsNullOrWhiteSpace($endpoint)) {
    $endpoint = "http://localhost/api/w/obsidian/jobs/run_wait_result/f/u/peterernst/scrape_markdown_article"
}

$token = [Environment]::GetEnvironmentVariable("WINDMILL_TOKEN")
if ([string]::IsNullOrWhiteSpace($token)) {
    $token = "lpWu39p3xrbGCT09CpdMRgnO2c4IDLIu"
}

$headers = @{
    "Content-Type"  = "application/json; charset=utf-8"
    "Authorization" = "Bearer $token"
}

$payload = @{
    url = $Url
} | ConvertTo-Json -Compress

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method POST -Headers $headers -Body $payload -TimeoutSec $TimeoutSec
} catch {
    $statusCode = 0
    $errorBody = ""

    if ($_.Exception.Response) {
        try {
            $statusCode = [int]$_.Exception.Response.StatusCode
        } catch {}

        try {
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                $errorBody = $_.ErrorDetails.Message
            } elseif ($_.Exception.Response.Content) {
                $errorBody = $_.Exception.Response.Content.ReadAsStringAsync().Result
            } else {
                $stream = $_.Exception.Response.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $errorBody = $reader.ReadToEnd()
                }
            }
        } catch {}
    }

    if ($statusCode -eq 401 -or $statusCode -eq 403) {
        Exit-WithError "Error (HTTP $statusCode): Authentication failed for Windmill endpoint. Verify WINDMILL_TOKEN." 1
    } elseif ($statusCode -eq 404) {
        Exit-WithError "Error (HTTP 404): Windmill endpoint route not found at $endpoint." 1
    } elseif ($statusCode -eq 422) {
        $extractedMsg = ""
        if (-not [string]::IsNullOrWhiteSpace($errorBody)) {
            try {
                $errJson = $errorBody | ConvertFrom-Json
                if ($errJson.error -and $errJson.error.message) {
                    $extractedMsg = ": " + $errJson.error.message
                }
            } catch {
                $extractedMsg = ": $errorBody"
            }
        }
        Exit-WithError "Error (HTTP 422): Article extraction failed for '$Url'$extractedMsg" 1
    } elseif ($statusCode -gt 0) {
        Exit-WithError "Error (HTTP $statusCode): Windmill job execution failed: $errorBody" 1
    } else {
        Exit-WithError "Error: Unable to connect to Windmill service at $endpoint. Ensure the local Windmill daemon or container is running." 1
    }
}

if ($null -eq $response) {
    Exit-WithError "Error: Empty response received from Windmill service." 1
}

if ($Format -eq "json") {
    $jsonOutput = $response | ConvertTo-Json -Depth 10
    [Console]::Out.WriteLine($jsonOutput)
    exit 0
}

# Format as Markdown with YAML frontmatter and callout
$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine("---")

$noteType = "capture"
if ($response.frontmatter -and $response.frontmatter.type) {
    $noteType = $response.frontmatter.type
}
[void]$sb.AppendLine("type: $noteType")

$sourceUrl = $Url
if ($response.source) {
    $sourceUrl = $response.source
}
[void]$sb.AppendLine("link: `"$sourceUrl`"")

$ttrVal = 0
if ($response.ttr) {
    $ttrVal = $response.ttr
}
[void]$sb.AppendLine("reading_time: $ttrVal")

# Authors list
$authorsArray = @()
if ($response.frontmatter -and $response.frontmatter.authors) {
    foreach ($a in $response.frontmatter.authors) {
        if (-not [string]::IsNullOrWhiteSpace($a)) {
            $cleanAuthor = $a.ToString().Replace('"', '\"')
            $authorsArray += "`"$cleanAuthor`""
        }
    }
} elseif ($response.frontmatter -and $response.frontmatter.author) {
    $cleanAuthor = $response.frontmatter.author.ToString().Replace('"', '\"')
    $authorsArray += "`"$cleanAuthor`""
}
[void]$sb.AppendLine("authors: [$($authorsArray -join ', ')]")

# Site name
$siteName = ""
if ($response.frontmatter -and $response.frontmatter.site) {
    $siteName = $response.frontmatter.site
}
[void]$sb.AppendLine("site: `"$siteName`"")

# Keywords
$keywordsArray = @()
if ($response.frontmatter -and $response.frontmatter.keywords) {
    foreach ($kw in $response.frontmatter.keywords) {
        if (-not [string]::IsNullOrWhiteSpace($kw)) {
            $cleanKw = $kw.ToString().Replace('"', '\"')
            $keywordsArray += "`"$cleanKw`""
        }
    }
}
[void]$sb.AppendLine("keywords: [$($keywordsArray -join ', ')]")

# Published timestamp
$publishedStr = ""
if ($response.frontmatter -and $response.frontmatter.published) {
    $publishedStr = $response.frontmatter.published
}
if (-not [string]::IsNullOrWhiteSpace($publishedStr)) {
    [void]$sb.AppendLine("published: $publishedStr")
}

# Publisher
if ($response.frontmatter -and $response.frontmatter.publisher) {
    $pub = $response.frontmatter.publisher.ToString().Replace('"', '\"')
    [void]$sb.AppendLine("publisher: `"$pub`"")
}

# Expires
if ($response.frontmatter -and $response.frontmatter.expires) {
    [void]$sb.AppendLine("expires: $($response.frontmatter.expires)")
}

[void]$sb.AppendLine("---")

# Callout header block
$articleTitle = ""
if ($response.frontmatter -and $response.frontmatter.title) {
    $articleTitle = $response.frontmatter.title
}
[void]$sb.AppendLine("> [!info]+ $articleTitle")

if ($response.frontmatter -and $response.frontmatter.image) {
    [void]$sb.AppendLine("> ![image|float:right|200]($($response.frontmatter.image))")
}

if ($response.frontmatter -and $response.frontmatter.description) {
    [void]$sb.AppendLine("> $($response.frontmatter.description)")
}

[void]$sb.AppendLine("")

# Article content body
if (-not [string]::IsNullOrWhiteSpace($response.article)) {
    [void]$sb.AppendLine($response.article)
} else {
    [void]$sb.AppendLine("_No article body extracted._")
}

[Console]::Out.WriteLine($sb.ToString())
exit 0
