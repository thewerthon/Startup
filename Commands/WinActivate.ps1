#Self-Elevate
If (!(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))) {

    $CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit

}

#Activate Windows
Write-Host "Activation script is running, please wait..."
Start-Process "C:\Windows\System32\cmd.exe" -ArgumentList "/c C:\Drivers\Ativador.cmd" -Wait
