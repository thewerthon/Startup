# Preferences
$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Load Args
$Args = (Get-Content -Path "C:\Startup\Args.txt" -Raw -ErrorAction Ignore) -Split '\s+'
