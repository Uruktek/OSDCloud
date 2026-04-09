# attempt to install the unattend.xml file to image before it boots.

$Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Add-unattend.log"
Start-Transcript -Path (Join-Path "C:\OSDCloud\Logs\" $Global:Transcript) -ErrorAction Ignore

try {
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/uruktek/OSDCloud/main/unattend.xml -OutFile C:\Windows\Panther\unattend.xml
    Write-host -ForegroundColor Green "unattend.xml has been downloaded to C:\Windows\Panther\unattend.xml"
}
catch {
    write-host "error within Add-unattend. :" $_
}


Stop-Transcript