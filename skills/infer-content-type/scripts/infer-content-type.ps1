<#
.SYNOPSIS
    Infers the most appropriate content type for a Markdown string using the configured OpenAI model.

.DESCRIPTION
    Reads the available type definitions from the companion JSON file, builds a multiple-choice
    prompt for the OpenAI Decisions API, and returns the selected content type along with confidence
    information.

.PARAMETER content
    The Markdown content to classify.

.EXAMPLE
    .\infer-content-type1.ps1 -content "# My Note\nThis is a summary of a project."

    Classifies the provided Markdown and returns a JSON object with the selected type and confidence.

.OUTPUTS
    System.String
    The script emits a JSON payload describing the selected content type, confidence score, and
    probability breakdown.

.NOTES
    File Name: infer-content-type.ps1
    Author: Copilot
    Requires: Windows PowerShell 5.1 or PowerShell 7+
    Requires the companion type-definition JSON file in the parent references folder.
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$content
)

$ErrorActionPreference = 'Stop'

try {
    if ([string]::IsNullOrWhiteSpace($content)) {
        throw 'The content parameter must not be empty.'
    }

    $typeDefinitionsPath = Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'references/type-definitions.json'
    if (-not (Test-Path -LiteralPath $typeDefinitionsPath -PathType Leaf)) {
        throw "Type definitions file not found: $typeDefinitionsPath"
    }

    $typeDefinitions = Get-Content -LiteralPath $typeDefinitionsPath -Encoding utf8 -Raw -ErrorAction Stop | ConvertFrom-Json
    if ($null -eq $typeDefinitions) {
        throw 'The type definitions file is empty or invalid JSON.'
    }

    $apiKey = $env:OPENAI_API_KEY
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw 'The OPENAI_API_KEY environment variable is not set. Configure it before running this script.'
    }

    $headers = @{
        Authorization = "Bearer $apiKey"
        'Content-Type' = 'application/json; charset=utf-8'
    }

    $choices = @($typeDefinitions | ForEach-Object {
        @{
            value = $_.Type
            description = $_.Definition
        }
    })

    if ($choices.Count -eq 0) {
        throw 'No content type definitions were loaded from the reference file.'
    }

    $questions = @(
        @{
            type = 'choice'
            name = 'type'
            instructions = 'Which type best describes the provided Markdown content?'
            choices = $choices
        }
    )

    $body = @{
        model = 'gpt-6-luna'
        input = $content
        questions = $questions
    } | ConvertTo-Json -Depth 10

    $requestBody = [System.Text.Encoding]::UTF8.GetBytes($body)
    $response = Invoke-RestMethod -Uri 'https://api.openai.com/v1/decisions' -Method Post -Headers $headers -Body $requestBody -ContentType 'application/json; charset=utf-8' -ErrorAction Stop

    if ($null -eq $response -or $null -eq $response.answers -or $response.answers.Count -eq 0) {
        throw 'The API response does not include any answers.'
    }

    $answer = @($response.answers)[0]
    if ($null -eq $answer -or $null -eq $answer.choice) {
        throw 'The API response is missing the selected content type.'
    }

    @{
        type = $answer.choice
        confidence = $answer.confidence
    } | ConvertTo-Json -Depth 10
}
catch {
    $message = $_.Exception.Message
    Write-Error "Failed to infer content type: $message"
    exit 1
}
