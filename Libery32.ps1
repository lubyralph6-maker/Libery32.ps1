try {
    Invoke-WebRequest $u -OutFile $f -UseBasicParsing
} catch {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub Releases first.' -ForegroundColor Red
    Write-Host $u -ForegroundColor Yellow
$downloaded = $false
foreach ($url in $urls) {
    if ([string]::IsNullOrWhiteSpace($url)) { continue }
    try {
        Write-Host "Downloading from $url ..."
        Invoke-WebRequest $url -OutFile $f -UseBasicParsing
        if ((Get-Item $f).Length -gt 100000) {
            $downloaded = $true
            break
        }
    } catch {
        Remove-Item $f -Force -ErrorAction SilentlyContinue
    }
}
if (-not $downloaded) {
    Write-Host 'Download failed. Upload Libery32.exe to GitHub first.' -ForegroundColor Red
    exit 1
}
Copy-Item $f $exe -Force
Remove-Item $f -Force -ErrorAction SilentlyContinue
if (-not (Test-Path $exe)) {
    Write-Host 'Libery32.exe not found after download.' -ForegroundColor Red
    exit 1
}
Start-Process -FilePath $exe -WorkingDirectory $t
Write-Host 'OK'
