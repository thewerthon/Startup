# Preferences
$VerbosePreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Self-Elevate
If (!(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))) {

    $CommandLine = "-File """ + $MyInvocation.MyCommand.Path + """ " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit

}

# Execution Policy
Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "LocalMachine" -Force -ErrorAction Ignore | Out-Null
Set-ExecutionPolicy -ExecutionPolicy "Unrestricted" -Scope "CurrentUser" -Force -ErrorAction Ignore | Out-Null

# Create Paths
New-Item -Path "HKLM:\Software\Startup" -ErrorAction Ignore | Out-Null
New-Item -ItemType Directory -Path "C:\Startup" -ErrorAction Ignore | Out-Null
Get-Item "C:\Startup" -ErrorAction Ignore | ForEach-Object { $_.Attributes = "Directory,System,Hidden" }

# Export Args
[String]$Args | Out-File "C:\Startup\Args.txt" -Force

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
    If ($InstallFlag) { Write-Host "Installing scripts..." -ForegroundColor Gray } Else { Write-Host "Updating scripts..." -ForegroundColor Gray }

    # Get Latest Release
    $ApiUrl = "https://api.github.com/repos/thewerthon/Startup/releases/latest"
    $Release = Invoke-RestMethod -Uri $ApiUrl
    $FileUrl = $Release.assets.browser_download_url

    # Check if exists
    If ($FileUrl) {

        # Download and Extract
        Invoke-WebRequest -Uri $FileUrl -OutFile "C:\Startup\Startup.zip"
        Expand-Archive -Path "C:\Startup\Startup.zip" -DestinationPath "C:\Startup" -Force
        
        # Register
        New-ItemProperty -Path "HKLM:\Software\Startup" -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

    }

}

# Install Scripts
If ($InstallFlag) {

    ForEach ($Task In @("Accent", "Glyphs", "Updater", "System", "User")) {

        # Install Tasks
        If (Test-Path "C:\Startup\Tasks\$Task.xml") { 

            Stop-ScheduledTask -TaskName $Task -TaskPath "Startup" -ErrorAction Ignore
            Get-ScheduledTask -TaskName $Task -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False
            Register-ScheduledTask -TaskName $Task -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\$Task.xml" | Out-String) -Force | Out-Null
            New-ItemProperty -Path "HKLM:\Software\Startup" -Name "Installed" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

        }

    }

}

# Run Updater Script
If ($RunUpdater -Or $RunAll) {

    Write-Host "Invoking updater script..." -ForegroundColor Gray
    If (Test-Path "C:\Startup\Scripts\Updater.ps1") { . "C:\Startup\Scripts\Updater.ps1" } Else { Write-Host "Updater script was not found!" -ForegroundColor Gray }

}

# Run System Script
If ($RunSystem -Or $RunAll) {

    Write-Host "Invoking system script..." -ForegroundColor Gray
    If (Test-Path "C:\Startup\Scripts\System.ps1") { . "C:\Startup\Scripts\System.ps1" } Else { Write-Host "System script was not found!" -ForegroundColor Gray }

}

# Run User Script
If ($RunUser -Or $RunAll) {

    Write-Host "Invoking user script in another window..." -ForegroundColor Gray
    If ($KeepFlag) { $UserScript = "C:\Startup\Helpers\UserKeep.vbs" } Else { $UserScript = "C:\Startup\Helpers\UserView.vbs" }
    If ((Test-Path $UserScript) -And (Test-Path "C:\Startup\Scripts\User.ps1")) { Start-Process Explorer $UserScript } Else { Write-Host "User script was not found!" -ForegroundColor Gray }

}

# Clean Up
Remove-Item "C:\Startup\Args.txt" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Startup.zip" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\README.md" -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Tasks" -Recurse -Force -ErrorAction Ignore
Remove-Item "C:\Startup\Setup" -Recurse -Force -ErrorAction Ignore

# Terminate
If ($KeepFlag) { Read-Host "Press [Enter] to exit" } Else { Exit }
