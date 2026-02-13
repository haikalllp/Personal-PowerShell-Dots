# sync_opencodetheme.ps1
# This script reads colors from wal colors.json and generates an OpenCode theme

# Paths
$walColorsPath = "$env:USERPROFILE\.cache\wal\colors.json"
$themePath = "$env:USERPROFILE\.config\opencode\themes\wal.json"
$themesDir = Split-Path $themePath -Parent

# Create themes directory if it doesn't exist
if (-not (Test-Path $themesDir)) {
    New-Item -ItemType Directory -Path $themesDir -Force | Out-Null
    Write-Host "Created directory: $themesDir"
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
$colorNames = @('color0', 'color1', 'color2', 'color3', 'color4', 'color5', 'color6', 'color7', 'color8', 'color9', 'color10', 'color11', 'color12', 'color13', 'color14', 'color15')

foreach ($colorName in $colorNames) {
    if ($walContent.colors.PSObject.Properties.Name -contains $colorName) {
        $colors[$colorName] = $walContent.colors.$colorName
    } else {
        Write-Error "Could not find $colorName in wal colors file"
        exit 1
    }
}

# Extract special colors
if ($walContent.special.PSObject.Properties.Name -contains 'background') {
    $colors['background'] = $walContent.special.background
} else {
    Write-Error "Could not find special.background in wal colors file"
    exit 1
}

if ($walContent.special.PSObject.Properties.Name -contains 'foreground') {
    $colors['foreground'] = $walContent.special.foreground
} else {
    Write-Error "Could not find special.foreground in wal colors file"
    exit 1
}

# Map wal colors to OpenCode theme
$themeMapping = @{
    'text' = $colors['foreground']
    'textMuted' = $colors['color8']
    'primary' = $colors['color4']
    'secondary' = $colors['color6']
    'accent' = $colors['color5']
    'error' = $colors['color1']
    'warning' = $colors['color3']
    'success' = $colors['color2']
    'info' = $colors['color12']
    'border' = $colors['background']
    'borderActive' = $colors['color4']
    'borderSubtle' = $colors['color8']
    'diffAdded' = $colors['color2']
    'diffRemoved' = $colors['color1']
    'diffContext' = $colors['color8']
    'diffHunkHeader' = $colors['color0']
    'diffHighlightAdded' = $colors['color2']
    'diffHighlightRemoved' = $colors['color1']
    'diffLineNumber' = $colors['color8']
    'markdownText' = $colors['foreground']
    'markdownHeading' = $colors['color4']
    'markdownLink' = $colors['color4']
    'markdownLinkText' = $colors['color6']
    'markdownCode' = $colors['color2']
    'markdownBlockQuote' = $colors['color3']
    'markdownEmph' = $colors['color3']
    'markdownStrong' = $colors['color5']
    'markdownHorizontalRule' = $colors['color8']
    'markdownListItem' = $colors['color4']
    'markdownListEnumeration' = $colors['color6']
    'markdownImage' = $colors['color4']
    'markdownImageText' = $colors['color6']
    'markdownCodeBlock' = $colors['foreground']
    'syntaxComment' = $colors['color8']
    'syntaxKeyword' = $colors['color5']
    'syntaxFunction' = $colors['color4']
    'syntaxVariable' = $colors['foreground']
    'syntaxString' = $colors['color2']
    'syntaxNumber' = $colors['color3']
    'syntaxType' = $colors['color5']
    'syntaxOperator' = $colors['color6']
    'syntaxPunctuation' = $colors['foreground']
}

# Create the theme object
$theme = @{
    '$schema' = "https://opencode.ai/theme.json"
    theme = @{
        background = "transparent"
        backgroundPanel = "transparent"
        backgroundElement = "transparent"
        diffAddedBg = "transparent"
        diffRemovedBg = "transparent"
        diffContextBg = "transparent"
        diffAddedLineNumberBg = "transparent"
        diffRemovedLineNumberBg = "transparent"
    }
}

# Add all the mapped colors to the theme
foreach ($key in $themeMapping.Keys) {
    $theme.theme[$key] = $themeMapping[$key]
}

# Convert to JSON and write to file
try {
    $jsonContent = $theme | ConvertTo-Json -Depth 10
    $jsonContent | Set-Content $themePath -Encoding UTF8
    Write-Host "OpenCode theme updated with pywal colors"
    Write-Host "Theme saved to: $themePath"
    Write-Host ""
    Write-Host "Key color mappings:"
    Write-Host "  text = $($themeMapping['text'])"
    Write-Host "  primary = $($themeMapping['primary'])"
    Write-Host "  secondary = $($themeMapping['secondary'])"
    Write-Host "  accent = $($themeMapping['accent'])"
    Write-Host "  error = $($themeMapping['error'])"
    Write-Host "  success = $($themeMapping['success'])"
    Write-Host "  syntaxKeyword = $($themeMapping['syntaxKeyword'])"
    Write-Host "  syntaxString = $($themeMapping['syntaxString'])"
} catch {
    Write-Error "Error writing theme file: $_"
    exit 1
}