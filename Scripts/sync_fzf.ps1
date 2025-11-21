# sync_fzf.ps1
# This script reads colors from wal colors.json and updates FZF_DEFAULT_OPTS and _ZO_FZF_OPTS
# to ensure fzf (including zi, Ctrl+r, and Ctrl+t) uses the dynamic pywal color palette

param(
    [switch]$FromStatic,   # Force static PSColors fallback
    [switch]$Print,        # Print effective values for verification
    [switch]$Silent        # Suppress success message when called from other functions
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
    # note bg is not used to avoid clashing with terminal bg
    $fg  = $wal.special.foreground
    $c0  = $wal.colors.color0
    $c2  = $wal.colors.color2
    $c3  = $wal.colors.color3
    $c4  = $wal.colors.color4
    $c5  = $wal.colors.color5
    $c6  = $wal.colors.color6
    $c8  = $wal.colors.color8
    $c13 = $wal.colors.color13
} else {
    # Static fallback: derive from PSReadLine palette if available
    $ps = $global:PSColors.PSReadLine
    $fg  = $ps.Default
    $c0  = '#2a2a2a'
    $c2  = $ps.String
    $c3  = $ps.Number
    $c4  = $ps.Command
    $c5  = $ps.Keyword
    $c6  = $ps.Member
    $c8  = $ps.Comment
    $c13 = $ps.Type
}

# Build fzf color map
$colorMap = @(
    "fg:$fg","hl:$c4",
    "fg+:$fg","bg+:$c0","hl+:$c6",
    "info:$c4","prompt:$c5","pointer:$c5",
    "marker:$c2","spinner:$c4","header:$c3",
    "border:$c8","query:$c13"
) -join ','

$colorOpt = "--color=$colorMap"

# ONLY set colors in FZF_DEFAULT_OPTS (layout options are handled by PSFZF module)
$env:FZF_DEFAULT_OPTS = $colorOpt

# Show success message for color sync (unless silent mode)
if (-not $Silent) {
    Write-Host "FZF Colors Loaded" -ForegroundColor Green
}

if ($Print) {
    Write-Host "FZF_DEFAULT_OPTS: $($env:FZF_DEFAULT_OPTS)"
}