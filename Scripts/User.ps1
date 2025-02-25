# Initialize
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# StartAllBack
Invoke-Script -Name "StartAllBack" -Folder "User" -Version 0 -AsUser {

    New-ItemProperty -Path "HKCU:\SOFTWARE\StartIsBack" -Name "Disabled" -Value "0" -Force | Out-Null

}

# Windows Apps
Invoke-Script -Name "Windows Apps" -Folder "User" -Version 0 -AsUser {

    . "C:\Startup\Scripts\Appx.ps1"

}

# OneDrive Sync
Invoke-Script -Name "OneDrive Sync" -Folder "User" -Version 0 -AsUser {

    $File = "C:\Startup\OneDrive\OneDriveSync.ps1"
    If (Test-Path $File) { PowerShell $File }

}

# Windows Registry
Invoke-Script -Name "Windows Registry" -Folder "User" -Version 1 -AsUser {

    # Remove Google Policies
    Remove-Item -Path "HKCU:\Software\Policies\Google" -Recurse -ErrorAction Ignore | Out-Null

    # Remove "Lear more about this picture" from Desktop
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{2cc5ca98-6485-489a-920e-b3e88a6ccce3" -Recurse -ErrorAction Ignore | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" -Value "1" -PropertyType DWord -Force | Out-Null

}