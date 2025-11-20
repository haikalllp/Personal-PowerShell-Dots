# sync_fd.ps1
# This script reads colors from wal colors.json and updates FD_DEFAULT_OPTS
# to ensure fd uses the dynamic pywal color palette when displaying file results

param(
    [switch]$FromStatic,   # Force static PSColors fallback
    [switch]$Print         # Print effective values for verification
)

$walPath = "$env:USERPROFILE\.cache\wal\colors.json"

# Try wal first unless forced static
$wal = $null
if (-not $FromStatic -and (Test-Path -LiteralPath $walPath)) {
    try {
        # Attempt to fix JSON formatting if needed (the script is idempotent)
        & "$PSScriptRoot\fix_json_formatting.ps1" -ColorsPath $walPath | Out-Null

        # Parse the JSON after potential fixing
        $wal = Get-Content -Path $walPath -Raw | ConvertFrom-Json
    } catch {
        # If parsing still fails, use static fallback
        Write-Verbose "Failed to parse colors.json, using static fallback"
        $wal = $null
    }
}

if ($wal) {
    # Use pywal colors
    # Map colors to fd color scheme
    $fg  = $wal.special.foreground
    $c1  = $wal.colors.color1  # Red for errors/warnings
    $c2  = $wal.colors.color2  # Green for success
    $c3  = $wal.colors.color3  # Yellow for special files
    $c4  = $wal.colors.color4  # Blue for directories
    $c5  = $wal.colors.color5  # Magenta for executables
    $c6  = $wal.colors.color6  # Cyan for links
    $c7  = $wal.colors.color7  # White for default text
    $c8  = $wal.colors.color8  # Bright black for dimmed text
} else {
    # Static fallback: derive from PSReadLine palette if available
    if ($global:PSColors -and $global:PSColors.PSReadLine) {
        $ps = $global:PSColors.PSReadLine
        $fg  = $ps.Default
        $c1  = $ps.Error
        $c2  = $ps.String
        $c3  = $ps.Number
        $c4  = $ps.Command
        $c5  = $ps.Keyword
        $c6  = $ps.Member
        $c7  = '#FFFFFF'
        $c8  = $ps.Comment
    } else {
        # Hardcoded fallback if PSColors is not available
        $fg  = '#FFFFFF'
        $c1  = '#FF5555'  # Red
        $c2  = '#50FA7B'  # Green
        $c3  = '#F1FA8C'  # Yellow
        $c4  = '#8BE9FD'  # Blue
        $c5  = '#FF79C6'  # Magenta
        $c6  = '#BD93F9'  # Cyan
        $c7  = '#FFFFFF'  # White
        $c8  = '#6272A4'  # Bright black
    }
}

# Helper function to convert hex color to ANSI RGB format
function Convert-HexToAnsi {
    param([string]$hex)

    # Remove # if present
    $hex = $hex -replace '^#', ''

    # Convert hex to RGB decimal values
    $r = [Convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4, 2), 16)

    return "$r;$g;$b"
}

# Build fd LS_COLORS format
# LS_COLORS format: filetype=text_attributes;foreground;background
$lsColors = @(
    "di=1;38;2;$(Convert-HexToAnsi $c4)",    # Directories: bold; foreground color
    "ex=1;38;2;$(Convert-HexToAnsi $c5)",    # Executables: bold; foreground color
    "ln=1;38;2;$(Convert-HexToAnsi $c6)",    # Symlinks: bold; foreground color
    "or=1;38;2;$(Convert-HexToAnsi $c1)",    # Orphaned symlinks: bold; foreground color
    "ow=1;38;2;$(Convert-HexToAnsi $c3)",    # Owner-writable: bold; foreground color
    "gr=38;2;$(Convert-HexToAnsi $c2)",      # Group-readable: foreground color
    "ur=38;2;$(Convert-HexToAnsi $c3)",      # User-readable: foreground color
    "uw=1;38;2;$(Convert-HexToAnsi $c1)",    # User-writable: bold; foreground color
    "ue=1;38;2;$(Convert-HexToAnsi $c5)",    # User-executable: bold; foreground color
    "su=1;48;2;$(Convert-HexToAnsi $c7);38;2;$(Convert-HexToAnsi $c1)", # SUID: bold; bg white; fg red
    "sf=1;48;2;$(Convert-HexToAnsi $c7);38;2;$(Convert-HexToAnsi $c1)"  # SGID: bold; bg white; fg red
) -join ':'

$colorOpt = "--color=always"

# Set LS_COLORS environment variable for fd
$env:LS_COLORS = $lsColors

# Show success message for color sync
Write-Host "FD Colors Loaded" -ForegroundColor Green

if ($Print) {
    Write-Host "LS_COLORS: $($env:LS_COLORS)"
}