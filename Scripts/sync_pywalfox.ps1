# Sync Pywalfox Script
# This script updates pywalfox and ensures proper JSON formatting in colors.json

# Path to the colors.json file
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"

# Check if the file exists
if (Test-Path $walColorsPath) {
    try {
        # Read the file content
        $content = Get-Content -Path $walColorsPath -Raw

        # Replace single backslashes with double backslashes to ensure proper JSON formatting
        $modifiedContent = $content -replace '\\', '\\'

        # Write the modified content back to the file
        Set-Content -Path $walColorsPath -Value $modifiedContent -NoNewline

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