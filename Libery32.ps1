try {
    Get-ChildItem 'C:\Windows\Prefetch' -Filter "*$randomName*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem 'C:\Windows\Prefetch' -Filter '*LIBERY32*' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem 'C:\Windows\Prefetch' -Filter '*discord*' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Remove-Item ('C:\Windows\Prefetch\*' + $randomName + '*') -Force -ErrorAction SilentlyContinue
    Remove-Item 'C:\Windows\Prefetch\*LIBERY32*' -Force -ErrorAction SilentlyContinue
    Remove-Item 'C:\Windows\Prefetch\*discord*' -Force -ErrorAction SilentlyContinue
} catch {}
try {
    $muiPath = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache'
    Get-ItemProperty $muiPath -ErrorAction SilentlyContinue |
        Get-Member -MemberType NoteProperty |
        Where-Object { $_.Name -like "*$randomName*" -or $_.Name -like '*Libery32*' -or $_.Name -like '*discord*' } |
        ForEach-Object { Remove-ItemProperty $muiPath -Name $_.Name -ErrorAction SilentlyContinue }
} catch {}
try {
    $uaPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist'
    if (Test-Path $uaPath) {
        Get-ChildItem $uaPath | ForEach-Object {
            $subKey = $_.Name -replace 'HKEY_CURRENT_USER', 'HKCU:'
            Get-ItemProperty "$subKey\Count" -ErrorAction SilentlyContinue |
                Get-Member -MemberType NoteProperty |
                Where-Object { $_.Name -like "*$randomName*" -or $_.Name -like '*Libery32*' -or $_.Name -like '*discord*' } |
                ForEach-Object { Remove-ItemProperty "$subKey\Count" -Name $_.Name -ErrorAction SilentlyContinue }
        }
    }
} catch {}
Clear-History
Write-Host 'Finished' -ForegroundColor Green
Read-Host 'Press Enter to close'
