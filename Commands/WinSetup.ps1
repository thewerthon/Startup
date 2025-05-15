# Self-Elevate
If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {

    $CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit

}

# Rename Computer
If ($Env:ComputerName -In ("WINDOWS-PC", "WINDOWS-11-PC", "VIRTUALBOX")) {

    Write-Host "`nRenaming Computer..." -ForegroundColor Green
    $ComputerName = Read-Host "Enter a name for the computer"
    If ($ComputerName -Ne $Env:ComputerName) { Rename-Computer $ComputerName -Force }

}

# Rename Volume
If ((Get-Volume -DriveLetter C).FileSystemLabel -Ne "Windows 11") {

    Write-Host "`nRenaming Volume..." -ForegroundColor Green
    Set-Volume -DriveLetter C -NewFileSystemLabel "Windows 11"

}

# Activate Windows
Write-Host "`nActivating Windows..." -ForegroundColor Green
Start-Process "C:\Windows\System32\cmd.exe" -ArgumentList "/c C:\Drivers\Ativador.cmd" -Wait

# Update Scripts
Write-Host "`nUpdating Scripts..." -ForegroundColor Green
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
Remove-Item "HKU:\.DEFAULT\Software\Startup" -Recurse -Force -ea Ignore
Remove-Item "HKCU:\Software\Startup" -Recurse -Force -ea Ignore
Remove-Item "HKLM:\Software\Startup" -Recurse -Force -ea Ignore
Invoke-Expression "& C:\Windows\Startup.ps1 update"

# Setup Users
If ((Get-LocalUser "Administrador").Enabled) {

    Write-Host "`nSetting Users..." -ForegroundColor Green
    $UserName = Read-Host "Enter a name for the user"
    New-LocalUser -Name $UserName -FullName $UserName -NoPassword -AccountNeverExpires | Out-Null
    Get-LocalUser -Name $UserName | Set-LocalUser -PasswordNeverExpires $True
    Add-LocalGroupMember -Group "Administradores" -Member $UserName
    Disable-LocalUser -Name "Administrador"

}

# Finish
Read-Host "Press [Enter] to exit..."
