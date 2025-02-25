# Preferences
$VerbosePreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

#Self-Elevate
If (!(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))) {

    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit

}

# Variables
$Folder = "C:\Startup"
$RegPath = "HKLM:\Software\Startup"
$FilePath = Join-Path $Folder "Startup.zip"
$Repository = "thewerthon/Startup"
$RepositoryPath = "$Repository/main/Startup.zip"

# Create Paths
New-Item -Path $RegPath -ErrorAction Ignore | Out-Null
New-Item -ItemType Directory -Path $Folder -ErrorAction Ignore | Out-Null
Get-Item $Folder -ErrorAction Ignore | ForEach-Object { $_.Attributes = "Directory,System,Hidden" }

# Export Args
[String]$Args | Out-File "$Folder\Args.txt" -Force

# Check Args
$KeepFlag = [String]$Args -Match "[-/]k"
$UpdateFlag = $Args -Contains "Update"
$InstallFlag = $Args -Contains "Install"
$RunUpdater = $Args -Contains "Updater"
$RunSystem = $Args -Contains "System"
$RunUser = $Args -Contains "User"
$RunAll = -Not ($RunUpdater -Or $RunSystem -Or $RunUser)

# Update Scripts
If ($UpdateFlag -Or $InstallFlag) {

    # Message
    If ($InstallFlag) { Write-Host "Installing scripts..." } Else { Write-Host "Updating scripts..." }

    # Get latest
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/$RepositoryPath" -OutFile $FilePath
    Expand-Archive -Path $FilePath -DestinationPath $Folder -Force

    # Register
    New-ItemProperty -Path $RegPath -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

}

# Install Scripts
If ($InstallFlag) {

    # Remove tasks
    If (Test-Path "$Folder\Tasks\Updater.xml") { Get-ScheduledTask -TaskName "Startup\Updater" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
    If (Test-Path "$Folder\Tasks\System.xml") { Get-ScheduledTask -TaskName "Startup\System" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
    If (Test-Path "$Folder\Tasks\User.xml") { Get-ScheduledTask -TaskName "Startup\User" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
	
    # Create tasks
    If (Test-Path "$Folder\Tasks\Updater.xml") { Register-ScheduledTask -TaskName "Startup\Updater" -Xml (Get-Content "$Folder\Tasks\Updater.xml" | Out-String) -Force | Out-Null }
    If (Test-Path "$Folder\Tasks\System.xml") { Register-ScheduledTask -TaskName "Startup\System" -Xml (Get-Content "$Folder\Tasks\System.xml" | Out-String) -Force | Out-Null }
    If (Test-Path "$Folder\Tasks\User.xml") { Register-ScheduledTask -TaskName "Startup\User" -Xml (Get-Content "$Folder\Tasks\User.xml" | Out-String) -Force | Out-Null }
	
    # Register
    New-ItemProperty -Path $RegPath -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

}

# Run Updater Script
If ($RunUpdater -Or $RunAll) {

    Write-Host ""
    Write-Host "Invoking updater script..."
    If (Test-Path "$Folder\Scripts\Updater.ps1") { . "$Folder\Scripts\Updater.ps1" } Else { Write-Host "Updater script was not found!" }

}

# Run System Script
If ($RunSystem -Or $RunAll) {

    Write-Host ""
    Write-Host "Invoking system script..."
    If (Test-Path "$Folder\Scripts\System.ps1") { . "$Folder\Scripts\System.ps1" } Else { Write-Host "System script was not found!" }

}

# Run User Script
If ($RunUser -Or $RunAll) {

    Write-Host ""
    Write-Host "Invoking user script..."
    Write-Host "Script will run in another window."
    If ($KeepFlag) { $UserScript = "$Folder\Helpers\UserKeep.vbs" } Else { $UserScript = "$Folder\Helpers\UserView.vbs" }
    If ((Test-Path $UserScript) -And (Test-Path "$Folder\Scripts\User.ps1")) { Start-Process Explorer $UserScript } Else { Write-Host "User script was not found!" }

}

# Clean Up
Remove-Item "$Folder\Args.txt" -Force
Remove-Item "$Folder\Startup.zip" -Force
Remove-Item "$Folder\README.md" -Force
Remove-Item "$Folder\Tasks" -Recurse -Force
Remove-Item "$Folder\Setup" -Recurse -Force

# Terminate
Write-Host ""
If ($KeepFlag) { Read-Host "Press [Enter] to exit" } Else { Exit }