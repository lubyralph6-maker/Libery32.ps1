# Libery32 - download, clean traces, run
# iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/RANVYX.ps1')

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dir = Join-Path $env:LOCALAPPDATA 'Libery32'
$exe = Join-Path $dir 'Libery32.exe'
$tmp = Join-Path $dir 'tmp.download'
$urls = @(
    'https://github.com/lubyralph6-maker/Libery32.ps1/raw/main/Libery32.exe',
    'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.exe'
)
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Libery32/1.2'

$traceDirs  = @('Libery32', 'RANVYX', 'RanvyxStore', 'FASTKILL', 'FourtyStoreLoader')
$traceWords = 'Libery32|RANVYX|Ranvyx|RuntimeBroker|FASTKILL|FastKill|lubyralph6|FourtyStore|ps-script|embed_assets'

function Remove-PathSafe([string]$Path, [switch]$Recurse) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try {
        if ($Recurse) { Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop }
        else { Remove-Item -LiteralPath $Path -Force -ErrorAction Stop }
        Write-Host "  removed: $Path" -ForegroundColor DarkGray
        return $true
    } catch {
        Write-Host "  skip: $Path" -ForegroundColor Yellow
        return $false
    }
}

function Clear-FileSafe([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    try {
        Set-Content -LiteralPath $Path -Value '' -Force -ErrorAction Stop
        Write-Host "  cleared: $Path" -ForegroundColor DarkGray
    } catch {}
}

function Clean-LocalTraces([string]$Phase) {
    Write-Host "Cleaning local traces ($Phase)..." -ForegroundColor Cyan

    if ($Phase -eq 'Before') {
        foreach ($name in $traceDirs) {
            if ($name -eq 'Libery32') {
                $p = Join-Path $env:LOCALAPPDATA $name
                if (Test-Path -LiteralPath $p) {
                    Remove-PathSafe (Join-Path $p 'tmp.download')
                    Remove-PathSafe (Join-Path $p 'Libery32.download')
                    Get-ChildItem -LiteralPath $p -File -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -match '\.download$|\.tmp$' } |
                        ForEach-Object { Remove-PathSafe $_.FullName }
                }
                continue
            }
            Remove-PathSafe (Join-Path $env:LOCALAPPDATA $name) -Recurse
        }
    }

    $local = $env:LOCALAPPDATA
    if (Test-Path -LiteralPath $local) {
        Get-ChildItem -LiteralPath $local -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match $traceWords } |
            ForEach-Object {
                if ($Phase -eq 'After' -and $_.FullName -eq $dir) { return }
                if ($Phase -eq 'Before' -and $_.FullName -eq $dir) { return }
                Remove-PathSafe $_.FullName -Recurse
            }
    }

    $tempRoots = @($env:TEMP, (Join-Path $env:LOCALAPPDATA 'Temp'))
    foreach ($root in $tempRoots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        Get-ChildItem -LiteralPath $root -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match $traceWords } |
            ForEach-Object { Remove-PathSafe $_.FullName }
        Get-ChildItem -LiteralPath $root -Filter 'ps-script-*.ps1' -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-PathSafe $_.FullName }
    }

    Clear-FileSafe "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    Clear-FileSafe "$env:APPDATA\Microsoft\PowerShell\PSReadLine\ConsoleHost_history.txt"

    $recent = Join-Path $env:APPDATA 'Microsoft\Windows\Recent'
    if (Test-Path -LiteralPath $recent) {
        Get-ChildItem -LiteralPath $recent -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match 'powershell|\.ps1|Libery32|RANVYX|Ranvyx|RuntimeBroker|FASTKILL' } |
            ForEach-Object { Remove-PathSafe $_.FullName }
    }

    $psLocal = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\PowerShell'
    if (Test-Path -LiteralPath $psLocal) {
        Get-ChildItem -LiteralPath $psLocal -Filter '*.etl' -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-PathSafe $_.FullName }
        Get-ChildItem -LiteralPath $psLocal -Filter 'StartupLog*.etl' -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-PathSafe $_.FullName }
    }

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
        IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        $prefetch = Join-Path $env:SystemRoot 'Prefetch'
        if (Test-Path -LiteralPath $prefetch) {
            Get-ChildItem -LiteralPath $prefetch -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match 'LIBERY32|RANVYX|RUNTIMEBROKER|FASTKILL|POWERSHELL|PWSH|PS\.EXE' } |
                ForEach-Object { Remove-PathSafe $_.FullName }
        }
    }

    if ($Phase -eq 'After') {
        Remove-PathSafe $tmp
        Remove-PathSafe (Join-Path $dir 'Libery32.download')
    }

    Write-Host 'Clean done.' -ForegroundColor Green
}

function Test-ValidExe([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try {
        $item = Get-Item -LiteralPath $Path
        if ($item.Length -lt 500KB) { return $false }
        $bytes = New-Object byte[] 2
        $stream = [IO.File]::OpenRead($Path)
        try { [void]$stream.Read($bytes, 0, 2) } finally { $stream.Dispose() }
        return ($bytes[0] -eq 0x4D -and $bytes[1] -eq 0x5A)
    } catch { return $false }
}

try {
    Clean-LocalTraces -Phase 'Before'

    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (-not (Test-ValidExe $exe)) {
        Write-Host 'Downloading Libery32.exe ...' -ForegroundColor Cyan
        $ok = $false
        foreach ($url in $urls) {
            for ($n = 1; $n -le 4; $n++) {
                try {
                    Remove-PathSafe $tmp
                    Write-Host "  try: $url" -ForegroundColor DarkGray
                    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -Headers @{ 'User-Agent' = $ua } -TimeoutSec 180
                    if (Test-ValidExe $tmp) {
                        Move-Item -LiteralPath $tmp -Destination $exe -Force
                        $ok = $true
                        break
                    }
                    throw 'invalid exe'
                } catch {
                    Start-Sleep -Seconds (3 * $n)
                }
            }
            if ($ok) { break }
        }
        if (-not $ok) { throw 'Cannot download Libery32.exe from GitHub' }
        Write-Host "Downloaded: $exe ($((Get-Item $exe).Length) bytes)" -ForegroundColor Green
    } else {
        Write-Host "Using cache: $exe" -ForegroundColor Green
    }

    Write-Host 'Starting as Administrator...' -ForegroundColor Cyan
    $proc = Start-Process -FilePath $exe -Verb RunAs -PassThru
    if ($null -eq $proc) { throw 'UAC cancelled' }
    Start-Sleep -Seconds 2
    if ($proc.HasExited) { throw "Exe closed immediately (exit $($proc.ExitCode))" }
    Write-Host 'Libery32 is running.' -ForegroundColor Green

    Clean-LocalTraces -Phase 'After'
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ''
Read-Host 'Press Enter to close'
