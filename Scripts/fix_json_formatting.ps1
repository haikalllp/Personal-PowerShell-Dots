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

        # First, try to parse the JSON as-is to check if it's already valid
        try {
            $null = $content | ConvertFrom-Json
            # JSON is already valid, no need to modify
            Write-Verbose "JSON is already valid, no modifications needed"
            return
        }
        catch {
            # JSON parsing failed, attempt to fix it
            Write-Verbose "JSON parsing failed, attempting to fix formatting"
        }

        # Replace single backslashes with double backslashes to ensure proper JSON formatting
        $modifiedContent = $content -replace '\\', '\\'

        # Verify that the modified content is valid JSON before writing
        try {
            $null = $modifiedContent | ConvertFrom-Json
            # Only write if the modified content is valid JSON
            Set-Content -Path $ColorsPath -Value $modifiedContent -NoNewline
            Write-Verbose "JSON formatting fixed and file updated"
            return
        }
        catch {
            Write-Host "Failed to fix JSON formatting - modified content is still invalid" -ForegroundColor Red
            return
        }
    }
    catch {
        Write-Host "Error occurred while fixing JSON formatting: $_" -ForegroundColor Red
        return
    }
} else {
    Write-Host "colors.json file not found at $ColorsPath" -ForegroundColor Red
    return
}