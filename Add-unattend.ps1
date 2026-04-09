# attempt to install the unattend.xml file to image before it boots.
Invoke-WebRequest -Uri https://raw.githubusercontent.com/uruktek/OSDCloud/main/unattend.xml -OutFile C:\Windows\Panther\unattend.xml
Write-host -ForegroundColor Green "unattend.xml has been downloaded to C:\Windows\Panther\unattend.xml"