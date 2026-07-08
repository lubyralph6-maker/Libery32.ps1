# Libery32 launcher - works with:
#   powershell -File .\Libery32.ps1
#   iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.ps1')

$ErrorActionPreference = 'Stop'

$exeName = 'Libery32.exe'
$installDir = Join-Path $env:LOCALAPPDATA 'Libery32'
$exePath = Join-Path $installDir $exeName
$exeUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.exe'
$webUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Libery32-Launcher/1.0'

function Write-Status([string]$Text, [string]$Color = 'White') {
    Write-Host $Text -ForegroundColor $Color
}

function Get-LocalExeNearScript {
    $root = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($root)) {
        return $null
    }
    $localExe = Join-Path $root $exeName
    if (Test-Path -LiteralPath $localExe) {
        return $localExe
    }
    return $null
}

function Invoke-DownloadWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [int]$MaxRetries = 6
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = $webUserAgent }

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -Headers $headers
            return
        }
        catch {
            $statusCode = $null
            if ($null -ne $_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }

            if ($statusCode -eq 429 -and $attempt -lt $MaxRetries) {
                $waitSeconds = [Math]::Min(90, [Math]::Pow(2, $attempt))
                Write-Status "GitHub rate limit (429). Retry in ${waitSeconds}s... ($attempt/$MaxRetries)" Yellow
                Start-Sleep -Seconds $waitSeconds
                continue
            }

            throw
        }
    }
}

function Get-CachedOrDownloadedExe {
    if (-not (Test-Path -LiteralPath $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $exePath) {
        Write-Status "Using cached: $exePath" Green
        return $exePath
    }

    Write-Status "Downloading: $exeUrl" Cyan
    Invoke-DownloadWithRetry -Uri $exeUrl -OutFile $exePath
    Write-Status 'Downloaded' Green

    if (-not (Test-Path -LiteralPath $exePath)) {
        throw 'Download failed - Libery32.exe not found after download.'
    }

    return $exePath
}

function Resolve-ExePath {
    $local = Get-LocalExeNearScript
    if ($null -ne $local) {
        return $local
    }
    return Get-CachedOrDownloadedExe
}

try {
    $targetExe = Resolve-ExePath
    if ([string]::IsNullOrWhiteSpace($targetExe)) {
        throw 'Could not resolve Libery32.exe path.'
    }

    Write-Status "Using: $targetExe" Green
    Write-Status 'Starting Libery32 (Administrator)...' Cyan

    $proc = Start-Process -FilePath $targetExe -Verb RunAs -PassThru
    if ($null -eq $proc) {
        throw 'Start-Process returned null.'
    }

    Start-Sleep -Seconds 2
    if ($proc.HasExited) {
        throw "Libery32 closed immediately (exit $($proc.ExitCode)). Install VC++ x64 Redistributable and add antivirus exclusion."
    }

    Write-Status 'Libery32 is running.' Green
    Write-Status 'Finished' Green
}
catch {
    Write-Status "Error: $($_.Exception.Message)" Red
    Write-Status 'Fix: upload Libery32.exe + Libery32.ps1 to GitHub, or copy exe + ps1 in same folder.' Yellow
    Write-Status 'If 429: wait 15-30 min, then run the link once (do not spam Enter).' Yellow
}

Write-Host ''
Read-Host 'Press Enter to close'
