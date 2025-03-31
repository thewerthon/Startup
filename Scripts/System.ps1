# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Hide Folders
Invoke-Script -Name "Hide Folders" -Folder "System" -RegHive "HKLM" -Version 0 {

    $Directories = @("C:\`$WINDOWS.~BT", "C:\`$WinREAgent", "C:\Startup", "C:\Autodesk", "C:\Drivers", "C:\Intel", "C:\Recovery", "C:\Log Files", "C:\PerfLogs", "C:\OneDriveTemp")
    ForEach ($Directory In $Directories) { If (Test-Path $Directory) { (Get-Item $Directory -ErrorAction Ignore) | ForEach-Object { $_.Attributes = "System, Hidden" } } }
	
}
