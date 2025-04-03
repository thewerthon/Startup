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

#Step 3: Update Scripts
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 3: Update Scripts         " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
Remove-Item "HKU:\.DEFAULT\Software\Startup" -Recurse -Force -ea Ignore
Remove-Item "HKCU:\Software\Startup" -Recurse -Force -ea Ignore
Remove-Item "HKLM:\Software\Startup" -Recurse -Force -ea Ignore
Invoke-Expression "& C:\Windows\Startup.ps1 update"

#Step 4: Enable BitLocker
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 4: Enable BitLocker       " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
While ($Answer -NotMatch "^[YyNn]$") { $Answer = Read-Host "Enable BitLocker for this device? (Y/N)" }
If ($Answer -Match "^[Yy]$") { Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes128 -UsedSpaceOnly -TpmProtector -SkipHardwareTest }

#Step 5: Setup Users
Write-Host "                               " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host "Step 5: Setup Users            " -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
$UserName = Read-Host "Enter a name for the user"
Disable-LocalUser -Name "Administrador"
New-LocalUser -Name $UserName -FullName $UserName -NoPassword -AccountNeverExpires | Out-Null
Get-LocalUser -Name $UserName | Set-LocalUser -PasswordNeverExpires $True
Add-LocalGroupMember -Group "Administradores" -Member $UserName
Write-Host "INFO: Administrator account was deactivated." -ForegroundColor Green
Write-Host "INFO: $UserName account was created." -ForegroundColor Green

#Finish
Write-Host "                               " -ForegroundColor Green
Read-Host "Press [Enter] to exit..."
