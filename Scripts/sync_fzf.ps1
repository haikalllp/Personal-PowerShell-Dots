# sync_fzf.ps1
# This script reads colors from wal colors.json and updates FZF_DEFAULT_OPTS and _ZO_FZF_OPTS
# to ensure fzf (including zi, Ctrl+r, and Ctrl+t) uses the dynamic pywal color palette

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
        & "$PSScriptRoot\fix_json_formatting.ps1" -ColorsPath $walPath

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
    $fg  = $wal.special.foreground
    # $bg  = $wal.special.background # (not used to avoid clash with terminal bg if transparent)
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
    # $bg  = '#1e1e1e' # (not used to avoid clash with terminal bg if transparent)
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
    "fg:$fg","bg:$bg","hl:$c4",
    "fg+:$fg","bg+:$c0","hl+:$c6",
    "info:$c4","prompt:$c5","pointer:$c5",
    "marker:$c2","spinner:$c4","header:$c3",
    "border:$c8","query:$c13"
) -join ','

$colorOpt = "--color=$colorMap"

# Merge into FZF_DEFAULT_OPTS (preserve existing flags, remove old --color if present)
if ([string]::IsNullOrWhiteSpace($env:FZF_DEFAULT_OPTS)) {
    # If FZF_DEFAULT_OPTS is not set, use default flags
    $base = '--height 40% --reverse --border --ansi'
} else {
    # Preserve existing flags but remove any existing --color
    $base = ($env:FZF_DEFAULT_OPTS -replace '--color=("[^"]+"|\S+)', '').Trim()
    # If base is empty after removing color, use default flags
    if ([string]::IsNullOrWhiteSpace($base)) {
        $base = '--height 40% --reverse --border --ansi'
    }
}
$env:FZF_DEFAULT_OPTS = @($base, $colorOpt) -join ' ' -replace '\s+', ' '

# Ensure zoxide interactive uses same palette (prefer color-only here)
if ([string]::IsNullOrWhiteSpace($env:_ZO_FZF_OPTS)) {
    $env:_ZO_FZF_OPTS = $colorOpt
} else {
    $env:_ZO_FZF_OPTS = ($env:_ZO_FZF_OPTS -replace '--color=("[^"]+"|\S+)', '').Trim()
    $env:_ZO_FZF_OPTS = @($env:_ZO_FZF_OPTS, $colorOpt) -join ' ' -replace '\s+', ' '
}

if ($Print) {
    Write-Host "FZF_DEFAULT_OPTS: $($env:FZF_DEFAULT_OPTS)"
    Write-Host "_ZO_FZF_OPTS   : $($env:_ZO_FZF_OPTS)"
}