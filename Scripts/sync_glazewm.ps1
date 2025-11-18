# sync_glazewm.ps1
# This script reads colors from wal colors.yml and updates the GlazeWM config

# Paths
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.yml"
$configPath = "$env:USERPROFILE\.glzr\glazewm\config.yaml"

# Read the wal colors file and extract color4 using regex
$walContent = Get-Content $walColorsPath -Raw
if ($walContent -match '\s+color4:\s*"([^"]+)"') {
    $color4 = $matches[1]
} else {
    exit 1
}

if ($walContent -match '\s+color0:\s*"([^"]+)"') {
    $color0 = $matches[1]
} else {
    exit 1
}

# Read the current config file to get the existing color
if (Test-Path $configPath) {
    $currentConfig = Get-Content $configPath -Raw
    if ($currentConfig -match "color: '([^']+)'") {
        $currentColor = $matches[1]
    } else {
        $currentColor = "#ffffff"  # Default fallback
    }
} else {
    $currentColor = "#ffffff"  # Default fallback
}

# Replace border colors with different colors for focused and unfocused windows
# For focused window border - use color4 (you can change this as needed)
$currentConfig = $currentConfig -replace "(?s)(focused_window:.*?border:.*?color:\s*)'#[A-Fa-f0-9]+'", "`$1'$color4'"

# For unfocused window border - use color0 (you can change this as needed)
$currentConfig = $currentConfig -replace "(?s)(other_windows:.*?border:.*?color:\s*)'#[A-Fa-f0-9]+'", "`$1'$color0'"

# Write the updated content back to the config file
$currentConfig | Set-Content $configPath

# reload glazewm to apply changes
glazewm command wm-reload-config

Write-Host "GlazeWM config updated: focused window border changed from '$currentColor' to '$color4', unfocused window border changed to '$color0'"