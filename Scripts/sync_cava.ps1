# sync_cava.ps1
# This script reads colors from wal colors.json and updates the Cava config

# Paths
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"
$configPath = "$env:USERPROFILE\.config\cava\config"

# Check if config exists
if (-not (Test-Path $configPath)) {
    Write-Error "Cava config file does not exist. Please create a Cava config first."
    exit 1
}

# Read the wal colors JSON file
try {
    $walContent = Get-Content $walColorsPath -Raw | ConvertFrom-Json
    if (-not $walContent) {
        Write-Error "Could not read wal colors file"
        exit 1
    }
} catch {
    Write-Error "Error parsing colors.json: $_"
    exit 1
}

# Extract colors from JSON
$colors = @{}
$colorNames = @('color0', 'color1', 'color2', 'color3', 'color4', 'color5', 'color6', 'color7')

foreach ($colorName in $colorNames) {
    if ($walContent.colors.PSObject.Properties.Name -contains $colorName) {
        $colors[$colorName] = $walContent.colors.$colorName
    } else {
        Write-Error "Could not find $colorName in wal colors file"
        exit 1
    }
}

# Read the current config
$configContent = Get-Content $configPath -Raw

# Create a new config content by replacing gradient colors
$newConfig = $configContent

# Map wal colors to gradient positions
# Using a visually pleasing order from the pywal color palette
$gradientMapping = @{
    'gradient_color_1' = $colors['color1']
    'gradient_color_2' = $colors['color3']
    'gradient_color_3' = $colors['color2']
    'gradient_color_4' = $colors['color6']
    'gradient_color_5' = $colors['color4']
    'gradient_color_6' = $colors['color5']
    'gradient_color_7' = $colors['color7']
    'gradient_color_8' = $colors['color0']
}

# Map wal colors to horizontal gradient positions
# Using a different visually pleasing order for horizontal gradient
$horizontalGradientMapping = @{
    'horizontal_gradient_color_1' = $colors['color1']
    'horizontal_gradient_color_2' = $colors['color2']
    'horizontal_gradient_color_3' = $colors['color3']
    'horizontal_gradient_color_4' = $colors['color4']
    'horizontal_gradient_color_5' = $colors['color5']
    'horizontal_gradient_color_6' = $colors['color6']
    'horizontal_gradient_color_7' = $colors['color7']
    'horizontal_gradient_color_8' = $colors['color0']
}

# Replace gradient colors in the config
foreach ($gradientColor in $gradientMapping.Keys) {
    # Use a simpler approach to replace just the color value
    $pattern = "($gradientColor\s*=\s*['`"])(#[^'`"]*)(['`"])"
    $replacement = "`$1$($gradientMapping[$gradientColor])`$3"
    $newConfig = $newConfig -replace $pattern, $replacement
}

# Replace horizontal gradient colors in the config (handle commented lines)
foreach ($gradientColor in $horizontalGradientMapping.Keys) {
    # Pattern to match commented or uncommented horizontal gradient color lines
    $pattern = ";\s*($gradientColor\s*=\s*['`"])(#[^'`"]*)(['`"])"
    $replacement = "$gradientColor = '$($horizontalGradientMapping[$gradientColor])'"
    $newConfig = $newConfig -replace $pattern, $replacement

    # Also handle already uncommented lines
    $pattern = "($gradientColor\s*=\s*['`"])(#[^'`"]*)(['`"])"
    $replacement = "`$1$($horizontalGradientMapping[$gradientColor])`$3"
    $newConfig = $newConfig -replace $pattern, $replacement
}

# Enable horizontal gradient by uncommenting the line if it exists
$newConfig = $newConfig -replace ";\s*(horizontal_gradient\s*=\s*1)", "horizontal_gradient = 1"

# Ensure gradient mode is enabled
$newConfig = $newConfig -replace "gradient\s*=\s*0", "gradient = 1"

# Write the updated content to the config file
$newConfig | Set-Content $configPath

Write-Host "Cava config updated with pywal colors"
Write-Host "Vertical gradient colors updated:"
foreach ($gradientColor in $gradientMapping.Keys) {
    Write-Host "  $gradientColor = $($gradientMapping[$gradientColor])"
}

Write-Host "Horizontal gradient colors updated:"
foreach ($gradientColor in $horizontalGradientMapping.Keys) {
    Write-Host "  $gradientColor = $($horizontalGradientMapping[$gradientColor])"
}