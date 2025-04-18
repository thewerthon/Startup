# Initialize
#Requires -RunAsAdministrator
. "C:\Startup\Scripts\Initialize.ps1"
. "C:\Startup\Scripts\Functions.ps1"

# Startup
Invoke-Script -Name "Startup" -Folder "Update" -RegHive "HKLM" -Version 1 {

    Get-RepositoryFile -Path "Commands\Startup.ps1"
    Copy-Item -Path "C:\Startup\Commands\Startup.ps1" -Destination "C:\Windows\Startup.ps1" -Force -ErrorAction Ignore
    
    Remove-Item "C:\Startup\Startup.ps1" -Force -ErrorAction Ignore
    Remove-Item "C:\Startup\Commands\Startup.ps1" -Force -ErrorAction Ignore
    
}

# AccentColorizer
Invoke-Script -Name "AccentColorizer" -Folder "Update" -RegHive "HKLM" -Version 2 {

    Get-RepositoryFile -Path "Tasks\Accent.xml"
    Get-RepositoryFile -Path "Tasks\Glyphs.xml"
    Get-RepositoryFile -Path "Setup\AccentColorizer.exe"
    Get-RepositoryFile -Path "Setup\AccentColorizer-E11.exe"

    Get-Process "AccentColorizer*" -ErrorAction Ignore | Stop-Process -Force -ErrorAction Ignore; Start-Sleep -Seconds 3
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer.exe" -Destination "C:\Windows\AccentColorizer.exe" -Force -ErrorAction Ignore
    Copy-Item -Path "C:\Startup\Setup\AccentColorizer-E11.exe" -Destination "C:\Windows\AccentColorizer-E11.exe" -Force -ErrorAction Ignore
    Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer" -Force -ErrorAction Ignore | Out-Null
    Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AccentColorizer-E11" -Force -ErrorAction Ignore | Out-Null

    ForEach ($Task In @("Accent", "Glyphs")) {

        If (Test-Path "C:\Startup\Tasks\$Task.xml") { 

            Stop-ScheduledTask -TaskName $Task -TaskPath "Startup" -ErrorAction Ignore
            Get-ScheduledTask -TaskName $Task -TaskPath "*Startup*" -ErrorAction Ignore | Unregister-ScheduledTask -Confirm:$False
            Register-ScheduledTask -TaskName $Task -TaskPath "Startup" -Xml (Get-Content "C:\Startup\Tasks\$Task.xml" | Out-String) -Force | Out-Null
            New-ItemProperty -Path "HKLM:\Software\Startup" -Name "Installed" -Value (Get-Date).ToString("s") -PropertyType "String" -Force | Out-Null
            Start-ScheduledTask -TaskName $Task -TaskPath "Startup" -ErrorAction Ignore

        }

    }

}

# Clean Up
Remove-Item "C:\Startup\Setup" -Recurse -Force -ErrorAction Ignore
