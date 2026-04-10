#================================================
#   [PreOS] Update Module
#================================================
Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "25H2"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    OSLicense = "Retail"
    ZTI = $true
    Firmware = $false
}
Start-OSDCloud @Params

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "AddNetFX3":  {
                      "IsPresent":  true
                  },
    "Autopilot":  {
                      "IsPresent":  false
                  },
    "RemoveAppx":  [
                    "MicrosoftTeams",
                    "Microsoft.BingWeather",
                    "Microsoft.BingNews",
                    "Microsoft.GamingApp",
                    "Microsoft.GetHelp",
                    "Microsoft.Getstarted",
                    "Microsoft.Messaging",
                    "Microsoft.MicrosoftOfficeHub",
                    "Microsoft.MicrosoftSolitaireCollection",
                    "Microsoft.MicrosoftStickyNotes",
                    "Microsoft.MSPaint",
                    "Microsoft.People",
                    "Microsoft.PowerAutomateDesktop",
                    "Microsoft.StorePurchaseApp",
                    "Microsoft.Todos",
                    "microsoft.windowscommunicationsapps",
                    "Microsoft.WindowsFeedbackHub",
                    "Microsoft.WindowsMaps",
                    "Microsoft.WindowsSoundRecorder",
                    "Microsoft.Xbox.TCUI",
                    "Microsoft.XboxGameOverlay",
                    "Microsoft.XboxGamingOverlay",
                    "Microsoft.XboxIdentityProvider",
                    "Microsoft.XboxSpeechToTextOverlay",
                    "Microsoft.YourPhone",
                    "Microsoft.ZuneMusic",
                    "Microsoft.ZuneVideo"
                   ],
    "UpdateDrivers":  {
                          "IsPresent":  false
                      },
    "UpdateWindows":  {
                          "IsPresent":  false
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

#================================================
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
Write-Host -ForegroundColor Green "Define Computername:"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$TargetComputername = $Serial.Substring(4,3)

$AssignedComputerName = "Win-$TargetComputername"
Write-Host -ForegroundColor Red $AssignedComputerName
Write-Host ""

Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
# $AutopilotOOBEJson = @"
# {
#     "AssignedComputerName" : "$AssignedComputerName",
#     "AddToGroup":  "AADGroupX",
#     "Assign":  {
#                    "IsPresent":  true
#                },
#     "GroupTag":  "GroupTagXXX",
#     "Hidden":  [
#                    "AddToGroup",
#                    "AssignedUser",
#                    "PostAction",
#                    "GroupTag",
#                    "Assign"
#                ],
#     "PostAction":  "Quit",
#     "Run":  "NetworkingWireless",
#     "Docs":  "https://google.com/",
#     "Title":  "Autopilot Manual Register"
# }
# "@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
# teno disabling of this.
#$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force


#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================

Write-Host -ForegroundColor Green "Create Create C:\Windows\Setup\Scripts\OOBE.cmd"
#Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://cleanup.osdcloud.ch
#Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/uruktek/OSDCloud/refs/heads/main/Add-unattend.ps1
$OOBECMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose
Start /Wait PowerShell -NoL -C Invoke-WebRequest -Uri "https://github.com/Uruktek/OSDCloud/raw/refs/heads/main/ppkg/Project_2.ppkg" -OutFile 'C:\OSDcloud\Automate\Provisioning\Project_2.ppkg' -Verbose
Start /Wait PowerShell -NoL -C Start-OOBEDeploy
'@
$OOBECMD | Out-File -FilePath 'Create C:\Windows\Setup\Scripts\OOBE.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -Command Set-ExecutionPolicy RemoteSigned -Force
Start /Wait PowerShell -NoL -C Invoke-WebRequest -Uri "https://github.com/Uruktek/OSDCloud/raw/refs/heads/main/ppkg/Project_2.ppkg" -OutFile 'C:\OSDcloud\Automate\Provisioning\Project_2.ppkg' -Verbose
Start /Wait PowerShell -NoL -C Install-ProvisioningPackage -PackagePath 'C:\OSDcloud\Automate\Provisioning\Project_2.ppkg' -Verbose
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
# Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
# Start-Sleep -Seconds 20
# wpeutil reboot