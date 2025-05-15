# Self-Elevate
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {

    $CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
    Start-Process -FilePath ConHost -Verb Runas -ArgumentList PowerShell, $CommandLine
    Exit

}

# Restore Health
Write-Host "Restoring system health..." -ForegroundColor Green
dism /Online /Cleanup-image /Restorehealth

# System Checker
Write-Host "Checking system files..." -ForegroundColor Green
sfc /scannow
