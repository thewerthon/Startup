# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Windows Apps
Invoke-Script -Name "Windows Apps" -Folder "System" -Version 0 -AsSystem {

    . "C:\Startup\Scripts\Appx.ps1"

}

# Windows Registry
Invoke-Script -Name "Windows Registry" -Folder "System" -Version 1 -AsSystem {

    # Remove Cloud Content Policies
    Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Recurse -ErrorAction Ignore | Out-Null

    # Enable Network Level Authentication
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value "1" -PropertyType DWord -Force | Out-Null

}