param(
    [string]$u = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/refs/heads/main/Libery32.exe',
    [string]$p = '',
    [string]$s = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/refs/heads/main/Libery32.ps1'
)

$ProgressPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Requesting Administrator... Click YES on UAC.' -ForegroundColor Cyan
    $ue = $u.Replace("'", "''")
    $pe = $p.Replace("'", "''")
    $se = $s.Replace("'", "''")
    Start-Process powershell -Verb RunAs -ArgumentList "-nop -ep bypass -NoExit -c `"`$u='$ue'; `$p='$pe'; iex (irm '$se')`""
    Write-Host 'If nothing happened, right-click PowerShell -> Run as administrator, then run again.' -ForegroundColor Yellow
    Read-Host 'Press Enter to close'
    exit
}

$t = if ($p -and (Test-Path $p)) { $p } else { Join-Path $env:LOCALAPPDATA 'Libery32' }
if (-not (Test-Path $t)) {
    New-Item -ItemType Directory -Path $t -Force | Out-Null
}

Get-Process Libery32 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$urls = @(
    $u,
    'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe'
)

$f = Join-Path $env:TEMP 'libery32.tmp'
$downloaded = $false
foreach ($url in $urls) {
    if ([string]::IsNullOrWhiteSpace($url)) { continue }
    try {
        Write-Host "Downloading Libery32.exe ..." -ForegroundColor Cyan
        Write-Host $url -ForegroundColor DarkGray
        Invoke-WebRequest $url -OutFile $f -UseBasicParsing
        if ((Get-Item $f).Length -gt 100000) {
            $downloaded = $true
            break
        }
        Write-Host 'File too small, trying next link...' -ForegroundColor Yellow
    } catch {
        Write-Host "Failed: $url" -ForegroundColor Yellow
        Remove-Item $f -Force -ErrorAction SilentlyContinue
    }
}

if (-not $downloaded) {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub first.' -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

$exe = Join-Path $t 'Libery32.exe'
Copy-Item $f $exe -Force
Remove-Item $f -Force -ErrorAction SilentlyContinue

Write-Host 'Launching Libery32...' -ForegroundColor Green
Start-Process -FilePath $exe -WorkingDirectory $t
Write-Host 'OK' -ForegroundColor Green
Read-Host 'Press Enter to close'
