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
$Repository = "thewerthon/startup"

# Create Paths
New-Item -Path $RegPath -ErrorAction Ignore | Out-Null
New-Item -ItemType Directory -Path $Folder -ErrorAction Ignore | Out-Null

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
    If ($InstallFlag) { Write-Host "Installing scripts..." } Else { Write-Host "Updating scripts..." }

    # Get latest release
    $ApiUrl = "https://api.github.com/repos/$Repository/releases/latest"
    $Release = Invoke-RestMethod -Uri $ApiUrl
    $FileUrl = $Release.zipball_url

    # Check if exists
    If ($FileUrl) {

        # Download and extract
        Invoke-WebRequest -Uri $FileUrl -OutFile $FilePath
        Expand-Archive -Path $FilePath -DestinationPath $Folder -Force
        $NewFolder = Get-ChildItem -Path "C:\Startup" -Directory | Where-Object { $_.Name -Like "$($Repository.Replace('/','-'))-*" }

        # Check if extracted
        If ($NewFolder) {

            # Move files
            Get-ChildItem -Path $NewFolder.FullName -Recurse | Where-Object { $_.FullName -NotLike "*\.*" } | ForEach-Object {

                $NewPath = $_.FullName.Replace($NewFolder.FullName, $Folder)
            
                If ($_.PSIsContainer) {

                    New-Item -ItemType Directory -Path $NewPath -ErrorAction Ignore | Out-Null

                } Else {

                    Move-Item -Path $_.FullName -Destination $NewPath -Force

                }

            }

            # Clear and register
            Remove-Item -Path $NewFolder.FullName -Recurse -Force
            New-ItemProperty -Path $RegPath -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

        }

    }

}

# Install Scripts
If ($InstallFlag) {

    # Remove tasks
    If (Test-Path "C:\Startup\Tasks\Updater.xml") { Get-ScheduledTask -TaskName "Startup\Updater" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
    If (Test-Path "C:\Startup\Tasks\System.xml") { Get-ScheduledTask -TaskName "Startup\System" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
    If (Test-Path "C:\Startup\Tasks\User.xml") { Get-ScheduledTask -TaskName "Startup\User" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False }
	
    # Create tasks
    If (Test-Path "C:\Startup\Tasks\Updater.xml") { Register-ScheduledTask -TaskName "Startup\Updater" -Xml (Get-Content "C:\Startup\Tasks\Updater.xml" | Out-String) -Force | Out-Null }
    If (Test-Path "C:\Startup\Tasks\System.xml") { Register-ScheduledTask -TaskName "Startup\System" -Xml (Get-Content "C:\Startup\Tasks\System.xml" | Out-String) -Force | Out-Null }
    If (Test-Path "C:\Startup\Tasks\User.xml") { Register-ScheduledTask -TaskName "Startup\User" -Xml (Get-Content "C:\Startup\Tasks\User.xml" | Out-String) -Force | Out-Null }
	
    # Clear and register
    New-ItemProperty -Path $RegPath -Name "Updated" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null

}

# Run Updater Script
If ($RunUpdater -Or $RunAll) {

    Write-Host "Invoking updater script..."
    If (Test-Path "C:\Startup\Scripts\Updater.ps1") { . "C:\Startup\Scripts\Updater.ps1" } Else { Write-Host "Updater script was not found!" }

}

# Run System Script
If ($RunSystem -Or $RunAll) {

    Write-Host "Invoking system script..."
    If (Test-Path "C:\Startup\Scripts\System.ps1") { . "C:\Startup\Scripts\System.ps1" } Else { Write-Host "System script was not found!" }

}

# Run User Script
If ($RunUser -Or $RunAll) {

    Write-Host "Invoking user script..."
    $UserScript = If ($KeepFlag) { "C:\Startup\Helpers\UserKeep.vbs" } Else { "C:\Startup\Helpers\UserView.vbs" }
    If (Test-Path $UserScript -And Test-Path "C:\Startup\Scripts\User.ps1") { Start-Process Explorer $UserScript } Else { Write-Host "User script was not found!" }

}

# Clear Args
Remove-Item "C:\Startup\Args.txt" -Force

# Terminate
If ($KeepFlag) { Read-Host "Press [Enter] to exit" } Else { Exit }