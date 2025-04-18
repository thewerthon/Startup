# Test Admin
Function Test-Admin {

	Return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')

}

# Invoke Script
Function Invoke-Script {

	Param (
		[Parameter(Mandatory = $True)][String]$Name,
		[ScriptBlock]$Code,
		[Int]$Version = 0,
		[String]$Folder,
		[String]$RegHive,
		[Switch]$ForceExecution,
		[Switch]$ForceRegister
	)
    
	# Check Register Path
	$RegName = $Name.Replace(' ', '')
	$RegFold = If ($Folder) { "\$($Folder)" }
	$RegPath = "$($RegHive):\Software\Startup\Versions$($RegFold)"

	# Create Register Path
	New-Item -Path "$($RegHive):\Software\Startup" -ErrorAction Ignore | Out-Null
	New-Item -Path "$($RegHive):\Software\Startup\Versions" -ErrorAction Ignore | Out-Null
	New-Item -Path "$($RegHive):\Software\Startup\Versions$($RegFold)" -ErrorAction Ignore | Out-Null

	# Check Version
	$CurrentVersion = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore | Select-Object -ExpandProperty $RegName
	If ([String]::IsNullOrEmpty($CurrentVersion)) { $CurrentVersion = 0 }

	# Check Execution
	If (($Version -Gt $CurrentVersion -Or $Version -Eq 0) -Or $ForceExecution) {

		Try {

			# Run Commands
			$Error.Clear()
			& $Code

		} Finally {

			# Check Errors
			If ($Error.Count -Gt 0) {
			
				Write-Host "There was a problem with $Name script." -ForegroundColor Red
				Write-Host $Error.Exception.Message -ForegroundColor Yellow
		
			} Else {

				Write-Host "$Name finished successfully!" -ForegroundColor Cyan

			}

			# Delete Execution
			If (($Version -Eq 0 -And $Error.Count -Eq 0) -Or $ForceRegister) {
			
				Remove-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore | Out-Null
		
			}

			# Register Execution
			If (($Version -Gt 0 -And $Error.Count -Eq 0) -Or $ForceRegister) {
			
				New-ItemProperty -Path $RegPath -Name $RegName -Value $Version -PropertyType "String" -Force -ErrorAction Ignore | Out-Null
		
			}

		}

	}

}

# Get Repository File
Function Get-RepositoryFile {

	Param (
		[Parameter(Mandatory = $True)][String]$Path
	)

	New-Item -Path "C:\Startup\$($Path | Split-Path)" -ItemType Directory -ErrorAction Ignore | Out-Null
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/thewerthon/Startup/main/$Path" -OutFile "C:\Startup\$($Path.Replace('/', '\'))"

}
