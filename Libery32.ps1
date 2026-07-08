# Libery32 - download exe then run
# iex (irm 'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/Libery32.ps1')

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dir  = Join-Path $env:LOCALAPPDATA 'Libery32'
$exe  = Join-Path $dir 'Libery32.exe'
$tmp  = Join-Path $dir 'Libery32.download'
$urls = @(
    'https://github.com/lubyralph6-maker/RANVYX.EXE/raw/main/Libery32.exe',
    'https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/Libery32.exe'
)
$ua   = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Libery32/1.2'

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

function Download-Exe {
    param([string[]]$UrlList, [string]$OutFile)
    $last = ''
    foreach ($url in $UrlList) {
        for ($n = 1; $n -le 4; $n++) {
            try {
                if (Test-Path -LiteralPath $OutFile) { Remove-Item $OutFile -Force -ErrorAction SilentlyContinue }
                Write-Host "  try: $url" -ForegroundColor DarkGray
                Invoke-WebRequest -Uri $url -OutFile $OutFile -UseBasicParsing -Headers @{ 'User-Agent' = $ua } -TimeoutSec 180
                if (Is-Exe $OutFile) { return $true }
                throw 'Downloaded file is not a valid .exe (upload Libery32.exe to GitHub)'
            } catch {
                $last = $_.Exception.Message
                $wait = if ($last -match '429') { 15 * $n } else { 3 * $n }
                Write-Host "  [$n/4] fail: $last" -ForegroundColor Yellow
                Start-Sleep -Seconds $wait
            }
        }
    }
    throw "Cannot download Libery32.exe - $last"
}

try {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (-not (Is-Exe $exe)) {
        Write-Host 'Downloading Libery32.exe ...' -ForegroundColor Cyan
        Download-Exe -UrlList $urls -OutFile $tmp
        Move-Item -LiteralPath $tmp -Destination $exe -Force
        Write-Host "Downloaded: $exe ($((Get-Item $exe).Length) bytes)" -ForegroundColor Green
    } else {
        Write-Host "Using cache: $exe" -ForegroundColor Green
    }

    Write-Host 'Starting as Administrator...' -ForegroundColor Cyan
    $p = Start-Process -FilePath $exe -Verb RunAs -PassThru
    if ($null -eq $p) { throw 'UAC cancelled' }
    Start-Sleep -Seconds 2
    if ($p.HasExited) { throw "Exe closed immediately (exit $($p.ExitCode))" }
    Write-Host 'Libery32 is running.' -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ''
Read-Host 'Press Enter to close'
