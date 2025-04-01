#Self-Elevate
If (!(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))) {

    $CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit

}

#Step 1: Rename Computer
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 1: Rename the Computer    " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Set-Volume -DriveLetter C -NewFileSystemLabel "Windows 11"
$ComputerName = Read-Host "Enter a name for the computer"
If ($ComputerName -ne $Env:ComputerName) { Rename-Computer $ComputerName -Force }

#Step 2: Activate Windows
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 2: Activate Windows       " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Activation script is running, please wait..." -ForegroundColor Green
Start-Process "C:\Windows\System32\cmd.exe" -ArgumentList "/c C:\Drivers\Ativador.cmd" -Wait

#Step 3: Setup Users
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 3: Setup Users            " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
$UserName = Read-Host "Enter a name for the user"
Disable-LocalUser -Name "Administrador"
New-LocalUser -Name $UserName -FullName $UserName -NoPassword -AccountNeverExpires | Out-Null
Get-LocalUser -Name $UserName | Set-LocalUser -PasswordNeverExpires $True
Add-LocalGroupMember -Group "Administradores" -Member $UserName
Write-Host "INFO: Administrator account was deactivated." -ForegroundColor Green
Write-Host "INFO: $UserName account was created." -ForegroundColor Green

#Step 4: Apply WinFix
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 4: Update Startup         " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Applying WinFix Script..." -ForegroundColor Green
Invoke-Expression "& C:\Windows\Startup.ps1 update"

#Finish
Write-Host "                               " -ForegroundColor Green
Read-Host "Press [Enter] to exit..."
