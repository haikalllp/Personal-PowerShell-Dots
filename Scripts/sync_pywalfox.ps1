# Sync Pywalfox Script
# This script updates pywalfox and ensures proper JSON formatting in colors.json

# Path to the colors.json file
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"

# Check if the file exists
if (Test-Path $walColorsPath) {
    try {
        # Fix JSON formatting first using centralized script
        & "$PSScriptRoot\fix_json_formatting.ps1" -ColorsPath $walColorsPath

        # Run pywalfox update
        pywalfox update
    }
    catch {
        Write-Host "Error occurred: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "colors.json file not found at $walColorsPath" -ForegroundColor Red
    exit 1
}