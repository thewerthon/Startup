Set WshShell = CreateObject("WScript.Shell")
Set AppShell = CreateObject("Shell.Application")
UserDir = WshShell.ExpandEnvironmentStrings("%UserProfile%")
AppShell.ShellExecute "PowerShell", "-NoLogo -NonInteractive -File C:\Startup\Scripts\User.ps1", UserDir, "Open", 0