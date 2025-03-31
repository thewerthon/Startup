Set MyShell = CreateObject("Shell.Application")
MyShell.ShellExecute "PowerShell", "-NoLogo -NonInteractive -File C:\Startup\Scripts\User.ps1", "", "", 1