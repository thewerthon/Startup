Set WshShell = CreateObject("WScript.Shell")
Set AppShell = CreateObject("Shell.Application")
UserDir = WshShell.ExpandEnvironmentStrings("%UserProfile%")
AppShell.ShellExecute "PowerShell", "-NoLogo -NoExit -File C:\Startup\OneDrive\OneDriveSync.ps1", UserDir, "Open", 1