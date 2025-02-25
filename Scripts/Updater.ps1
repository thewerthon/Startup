# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Startup
Invoke-Script -Name "Startup" -Folder "Update" -Version 2 -AsSystem {

    Copy-Item -Path "C:\Startup\Startup.ps1" -Destination "C:\Windows\Startup.ps1" -Force -ErrorAction Ignore

}

# StartAllBack
Invoke-Script -Name "StartAllBack" -Folder "Update" -Version 2 -AsSystem {

    Get-RepositoryFile -Path "Setup\StartAllBackCfg.exe"
    Start-Process "C:\Startup\Setup\StartAllBackCfg.exe" -ArgumentList "/uninstall /silent" -Wait; Start-Sleep -Seconds 3
    Remove-Item -Path "C:\Startup\Setup\StartAllBackCfg.exe" -Force -ErrorAction Ignore 

}

# AccentColorizer
Invoke-Script -Name "AccentColorizer" -Folder "Update" -Version 1 -AsSystem {

    Get-RepositoryFile -Path "Setup\AccentColorizer.exe"
    Get-RepositoryFile -Path "Setup\AccentColorizer-E11.exe"

    Get-Process "AccentColorizer*" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore
    Start-Sleep -Seconds 3
    
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer.exe" -Destination "C:\Windows\AccentColorizer.exe" -Force -ErrorAction Ignore
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer-E11.exe" -Destination "C:\Windows\AccentColorizer-E11.exe" -Force -ErrorAction Ignore

    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer" -Value "C:\Windows\AccentColorizer.exe" -PropertyType "String" -Force -ErrorAction Ignore | Out-Null
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer-E11" -Value "C:\Windows\AccentColorizer-E11.exe" -PropertyType "String" -Force -ErrorAction Ignore | Out-Null

    Remove-Item -Path "C:\Startup\Setup\AccentColorizer.exe" -Force -ErrorAction Ignore
    Remove-Item -Path "C:\Startup\Setup\AccentColorizer-E11.exe" -Force -ErrorAction Ignore
    
}