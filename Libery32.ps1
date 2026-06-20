$ErrorActionPreference = 'Stop'

$git = 'C:\Program Files\Git\bin\git.exe'
if (-not (Test-Path $git)) {
    Write-Host 'Git not found. Install Git for Windows first.' -ForegroundColor Red
    Read-Host 'Press Enter'
    exit 1
}

$project = Split-Path $PSScriptRoot -Parent
$repoUrl = 'https://github.com/lubyralph6-maker/Libery32.ps1.git'
$work = Join-Path $env:TEMP 'Libery32-github-fix'

if (Test-Path $work) {
    Remove-Item $work -Recurse -Force
}

Write-Host 'Cloning repo...' -ForegroundColor Cyan
& $git clone $repoUrl $work

Copy-Item (Join-Path $project 'Libery32.ps1') (Join-Path $work 'Libery32.ps1') -Force

$exeSrc = Join-Path $project 'build\Release\Libery32.exe'
if (Test-Path $exeSrc) {
    Copy-Item $exeSrc (Join-Path $work 'Libery32.exe') -Force
}

$local = Get-Content (Join-Path $work 'Libery32.ps1') -Raw
if (-not $local.StartsWith('param')) {
    Write-Host 'Local Libery32.ps1 is invalid.' -ForegroundColor Red
    exit 1
}

Write-Host ('Local script OK, length=' + $local.Length) -ForegroundColor Green

Push-Location $work
try {
    & $git add Libery32.ps1
    if (Test-Path (Join-Path $work 'Libery32.exe')) {
        & $git add Libery32.exe
    }

    & $git -c user.email='upload@local' -c user.name='upload' commit -m 'Fix Libery32.ps1 - upload complete script'

    Write-Host 'Pushing to GitHub... (login if asked)' -ForegroundColor Cyan
    & $git push origin main

    Write-Host 'Push OK. Waiting for raw cache...' -ForegroundColor Green
    Start-Sleep -Seconds 3

    $remote = Invoke-RestMethod 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.ps1'
    if ($remote.StartsWith('param')) {
        Write-Host 'VERIFY OK: GitHub file starts with param' -ForegroundColor Green
        Write-Host ''
        Write-Host "Run this:" -ForegroundColor Yellow
        Write-Host "iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.ps1')"
    } else {
        Write-Host 'VERIFY FAILED: GitHub still broken. Wait 1 minute and test again.' -ForegroundColor Red
    }
}
finally {
    Pop-Location
}

Read-Host 'Press Enter to close'
