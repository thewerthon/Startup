# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# StartAllBack
Invoke-Script -Name "StartAllBack" -Folder "Update" -Version 1 -AsSystem {

    Remove-Item "C:\Program Files\StartAllBack\StartAllBackCfg.exe" -Force -ErrorAction Ignore | Out-Null

}