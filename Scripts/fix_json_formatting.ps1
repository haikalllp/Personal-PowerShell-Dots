# fix_json_formatting.ps1
# This script ensures proper JSON formatting in colors.json by replacing single backslashes with double backslashes
# This is needed because pywal sometimes generates invalid JSON with single backslashes

param(
    [string]$ColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"
)

# Check if file exists
if (Test-Path $ColorsPath) {
    try {
        # Read file content
        $content = Get-Content -Path $ColorsPath -Raw

        # Replace single backslashes with double backslashes to ensure proper JSON formatting
        $modifiedContent = $content -replace '\\', '\\'

        # Write modified content back to file
        Set-Content -Path $ColorsPath -Value $modifiedContent -NoNewline

        return $true
    }
    catch {
        Write-Host "Error occurred while fixing JSON formatting: $_" -ForegroundColor Red
        return $false
    }
} else {
    Write-Host "colors.json file not found at $ColorsPath" -ForegroundColor Red
    return $false
}