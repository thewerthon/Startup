Set MyShell = CreateObject("Shell.Application")
MyShell.ShellExecute "PowerShell", "-NoLogo -NoExit -NonInteractive -File C:\Startup\Scripts\User.ps1", "", "", 1