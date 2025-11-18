# sync_komorebi.ps1
# This script reads colors from wal colors.json and updates Komorebi config

# Paths
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"
$configPath = "$env:USERPROFILE\.config\komorebi\komorebi.json"

# Read the wal colors file
if (Test-Path $walColorsPath) {
    try {
        # Fix JSON formatting first using centralized script
        & "$PSScriptRoot\fix_json_formatting.ps1" -ColorsPath $walColorsPath
        
        # Now read the modified content as JSON
        $walContent = Get-Content $walColorsPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "Error occurred while processing colors.json: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Wal colors file not found at $walColorsPath"
    exit 1
}

# Extract colors from the wal colors
$color4 = $walContent.colors.color4  # Will be used for focused windows
$color0 = $walContent.colors.color0  # Will be used for unfocused windows
$color6 = $walContent.colors.color6  # Alternative accent color

# Read the current komorebi config file
if (Test-Path $configPath) {
    $currentConfig = Get-Content $configPath -Raw | ConvertFrom-Json
} else {
    Write-Host "Komorebi config file not found at $configPath"
    exit 1
}

# Store current colors for comparison
$previousSingle = $currentConfig.border_colours.single
$previousStack = $currentConfig.border_colours.stack
$previousMonocle = $currentConfig.border_colours.monocle
$previousUnfocused = $currentConfig.border_colours.unfocused

# Update the border colors
$currentConfig.border_colours.single = $color4
$currentConfig.border_colours.stack = $color6
$currentConfig.border_colours.monocle = $color4
$currentConfig.border_colours.unfocused = $color0

# Convert back to JSON and write to file
$currentConfig | ConvertTo-Json -Depth 10 | Set-Content $configPath

# Reload komorebi to apply changes
komorebic reload-configuration

Write-Host "Komorebi config updated:"
Write-Host "  Single border: $previousSingle -> $color4"
Write-Host "  Stack border: $previousStack -> $color6"
Write-Host "  Monocle border: $previousMonocle -> $color4"
Write-Host "  Unfocused border: $previousUnfocused -> $color0"