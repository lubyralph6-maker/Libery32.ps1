# Libery32 launcher - works with:
#   powershell -File .\Libery32.ps1
#   iex (irm 'https://.../Libery32.ps1')

$ErrorActionPreference = 'Stop'

$exeName = 'Libery32.exe'
$installDir = Join-Path $env:LOCALAPPDATA 'Libery32'
$exePath = Join-Path $installDir $exeName
$exeUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.exe'

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

function Get-CachedOrDownloadedExe {
    if (-not (Test-Path -LiteralPath $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $exePath) {
        return $exePath
    }

    Write-Status "Downloading: $exeUrl" Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
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
    Write-Status 'Fix: upload Libery32.exe to GitHub, or copy exe + ps1 in same folder.' Yellow
}

Write-Host ''
Read-Host 'Press Enter to close'
