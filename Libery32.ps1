$assetsDir = Join-Path $installDir 'assets'
$tmpExe = Join-Path $env:TEMP 'libery32.tmp'
$tmpZip = Join-Path $env:TEMP 'libery32_assets.tmp'
Get-Process Libery32 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$f = Join-Path $env:TEMP 'libery32.tmp'
try {
    Write-Host "Downloading Libery32.exe ..."
    Get-RemoteFile $u $tmpExe
    Copy-Item $tmpExe $exePath -Force
} finally {
    Remove-Item $tmpExe -Force -ErrorAction SilentlyContinue
    Invoke-WebRequest $u -OutFile $f -UseBasicParsing
} catch {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub Releases first.' -ForegroundColor Red
    Write-Host $u -ForegroundColor Yellow
    exit 1
}
if ($a) {
    try {
        Write-Host "Downloading assets.zip ..."
        Get-RemoteFile $a $tmpZip
        if (-not (Test-Path $assetsDir)) {
            New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
        }
        Expand-Archive -Path $tmpZip -DestinationPath $installDir -Force
    } finally {
        Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
    }
}
$exe = Join-Path $t 'Libery32.exe'
Copy-Item $f $exe -Force
Remove-Item $f -Force -ErrorAction SilentlyContinue
if (-not (Test-Path $exePath)) {
    Write-Error 'Libery32.exe not found after download.'
if (-not (Test-Path $exe)) {
    Write-Host 'Libery32.exe not found after download.' -ForegroundColor Red
    exit 1
}
Start-Process -FilePath $exePath -WorkingDirectory $installDir
Write-Host 'OK' -ForegroundColor Green
Start-Process -FilePath $exe -WorkingDirectory $t
Write-Host 'OK'
