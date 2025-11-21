#region Header & Documentation
#================================================================================
# PowerShell Profile
# Author: haikalllp
# GitHub: https://github.com/haikalllp
# Description: Enhanced PowerShell profile with development tools and productivity utilities
#================================================================================

# Dependencies
#================================================================================
# This profile requires the following external dependencies:
#
# Required Dependencies:
# - PowerShell 7+
# - PSReadLine (usually included with PowerShell)
# - Oh My Posh (https://ohmyposh.dev/) - Theme engine for enhanced prompt
# - zoxide (https://github.com/ajeetdsouza/zoxide) - Smart directory navigation
# - FZF (https://github.com/junegunn/fzf) - Fuzzy finder for files/history
# - fd (https://github.com/sharkdp/fd) - Fast file finder for FZF integration
# - ripgrep (https://github.com/BurntSushi/ripgrep) - Fast text search for FZF
# - Terminal-Icons (PowerShell module) - File icons for enhanced ls output
# - PSFzf (PowerShell module) - PowerShell integration for FZF
# - fastfetch (https://github.com/fastfetch-cli/fastfetch) - System info display
# - nvim (https://neovim.io/) - Preferred editor for profile editing
# - pywal/winwal (https://github.com/scaryrawr/winwal) - Dynamic terminal theming
# - ImageMagick (https://imagemagick.org/) - Image processing for pywal
# - Visual Studio Code - Default fallback editor
#
# Required Development Tools:
# - winget - For PowerShell updates
# - Choco - For dependencies
# - pip - For pip dependent packages
#
# Complete Required Dependencies installation commands:
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco install oh-my-posh zoxide fzf ripgrep fastfetch neovim fd -y
# Install-Module -Name Terminal-Icons -Repository PSGallery
# Install-Module -Name PSFzf -Scope CurrentUser
# git clone https://github.com/scaryrawr/winwal "$HOME\Documents\PowerShell\Modules\winwal"
# rm -Path "$HOME\Documents\PowerShell\Modules\winwal\.git" -r -fo
# winget install imagemagick.imagemagick
# winget install Python.Python.3.13
# pip install pywal colorthief colorz haishoku
#
#================================================================================
# Optional Dependencies:
# - GlazewM (https://github.com/glzr-io/glazewm) - Window tiling manager
# - Komorebi (https://github.com/LGUG2Z/komorebi) - Alternative window tiling manager
# - Yasb (https://github.com/amnweb/yasb) - Windows Top Status bar
# - Cava (https://github.com/karlstav/cava) - Console-based Audio Visualizer
# - BetterDiscord (https://betterdiscord.app/) - Themed Discord client
# - Pywalfox (https://github.com/Frewacom/pywalfox) - Firefox theme sync with pywal
#================================================================================
#endregion


#region User Configurations
#================================================================================
# All user-configurable settings:

# Default Editor Configuration
# Valid values: "notepad", "neovim", "vscode"
# Determines which editor to use for file editing operations
$global:DefaultEditor = "vscode"

# Window Tiling Manager Configuration
# Valid values: "komorebi", "glazewm", "none"
# Only one should be active at a time
$global:WindowTilingManager = "glazewm"

# Optional Theme Sync Configuration
# Set to $true if you have the corresponding application installed and want theme sync
$global:SyncYasb = $true             # Set to $true if using Yasb and want pywal theme sync
$global:SyncNeovim = $true           # Set to $true if using Neovim
$global:SyncCava = $true             # Set to $true if using Cava
$global:SyncBetterDiscord = $false   # Set to $true if using BetterDiscord
$global:SyncPywalfox = $true         # Set to $true if using Pywalfox

# Startup Diagnostics Configuration
# Set to $false to prevent Clear-Host from clearing warnings/errors during startup
$global:ClearOnStartup = $true


#=================================================================================
# Oh My Posh Theme Mode Configuration
# Valid values: "local" (use local if exists, else remote with warning), "remote" (always use remote)
$global:OhMyPoshThemeMode = "local"

# For local themes can be any custom theme in any path. Here we use cached wal theme if available.
# You can generate a pywal oh-my-posh theme with winwal:
# Update-WalTheme; . $PROFILE
$ompLocal   = Join-Path $HOME ".cache\wal\posh-wal-atomic.omp.json"

# Fallback to normal remote theme if local custom theme not found (using raw URL)
$ompRemote  = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json"


#=================================================================================
# Centralized color configuration for PSStyles and PSReadLineOptions
# Modify Powershell colors here

# Dynamic PSReadLine/PSStyle Colors from Pywal/winwal
# You can customize which pywal colors map to which PSReadLine tokens
$global:DynamicPSColors = @{
    Command = 'color4'        # using color4 for commands
    Comment = 'color8'        # using color8 for comments
    Default = 'foreground'    # using foreground for default
    Emphasis = 'color3'       # using color3 for emphasis
    Error = 'color1'          # using color1 for errors
    Keyword = 'color5'        # using color5 for keywords
    Member = 'color6'         # using color6 for members
    Number = 'color3'         # using color3 for numbers
    Operator = 'color5'       # using color5 for operators
    Parameter = 'color14'     # using color14 for parameters
    String = 'color2'         # using color2 for strings
    Type = 'color13'          # using color13 for types
    Variable = 'color12'      # using color12 for variables
}

$global:PSColors = @{
    # PSReadLine Colors (static colors)
    # These will be used as fallbacks if pywal colors are not available
    PSReadLine = @{
        Command = '#87CEEB'       # SkyBlue (fallback)
        Comment = '#D3D3D3'       # LightGray (fallback)
        Default = '#FFFFFF'       # White (fallback)
        Emphasis = '#FFB6C1'      # LightPink (fallback)
        Error = '#FF6347'         # Tomato (fallback)
        Keyword = '#8367c7'       # Violet (fallback)
        Member = '#98FB98'        # PaleGreen (fallback)
        Number = '#B0E0E6'        # PowderBlue (fallback)
        Operator = '#FFB6C1'      # LightPink (fallback)
        Parameter = '#98FB98'     # PaleGreen (fallback)
        String = '#FFDAB9'        # PeachPuff (fallback)
        Type = '#F0E68C'          # Khaki (fallback)
        Variable = '#DDA0DD'      # Plum (fallback)
    }

    # UI 'PSStyles' Colors for various output
    # These will be used as fallbacks if pywal colors are not available
    UI = @{
        HelpTitle = 'Cyan'
        HelpSeparator = 'Yellow'
        HelpCommand = 'BrightMagenta'
        HelpCategory = 'Yellow'
        Success = 'Green'
        Warning = 'Yellow'
        Error = 'Red'
        Info = 'Cyan'
    }
}
#================================================================================
#endregion


#! ================================================================================
#!
#! WARNING!!
#! DO NOT TOUCH BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
#!
#! ================================================================================

#region Environment Setup & Diagnostics
#================================================================================
# CORE PROFILE LOGIC - Environment initialization and diagnostics system
#================================================================================

#================================================================================
# Startup Diagnostics System
#================================================================================
# Capture warnings during profile loading to display after fastfetch
$script:__profileWarnings = @()
$script:__profileErrorCountStart = $Error.Count

#================================================================================
# Diagnostics Functions
#================================================================================

function Add-ProfileWarning {
    param([string]$Message)
    $script:__profileWarnings += $Message
    Write-Warning $Message
}

function Show-StartupDiagnostics {
    # Warnings
    if ($script:__profileWarnings.Count -gt 0) {
        Write-Host "`n=== Profile Startup Warnings ===" -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
        $script:__profileWarnings | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    }

    # Errors added during this profile load only
    $errorStart = if ($script:__profileErrorCountStart) { $script:__profileErrorCountStart } else { 0 }
    $delta = $Error.Count - $errorStart
    if ($delta -le 0) { return }

    $startupErrors = $Error[0..([Math]::Min(9, $delta - 1))]
    $unique = @()
    $seen = @{}
    foreach ($err in $startupErrors) {
        $msg = $err.Exception.Message
        if ($msg -match '__zoxide_hooked') { continue }
        if (-not $seen.ContainsKey($msg)) {
            $seen[$msg] = $true
            $unique += $err
        }
    }

    if ($unique.Count -gt 0) {
        Write-Host "`n=== Profile Startup Errors ===" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        $unique | ForEach-Object {
            $origin = if ($_.InvocationInfo.MyCommand) { " ($($_.InvocationInfo.MyCommand))" } else { "" }
            Write-Host "  $($_.Exception.Message)$origin" -ForegroundColor Red
        }
    }
}

#================================================================================
# Module Path Configuration
#================================================================================

# Set all module paths
$modulePaths = @(
    "$HOME\scoop\modules",
    "$HOME\Documents\PowerShell\Modules",
    "$HOME\Documents\WindowsPowerShell\Modules"
)

$existingPaths = $env:PSModulePath -split ';'
$newPaths = $modulePaths | Where-Object { $_ -notin $existingPaths }
if ($newPaths) { $env:PSModulePath = "$($env:PSModulePath);$($newPaths -join ';')" }

#================================================================================
# Core Helper Functions
#================================================================================

function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Define fastfetch command for consistent usage throughout the profile
# Check if fastfetch is available and use the same reference everywhere
$global:fastfetch = if (Test-CommandExists fastfetch) { 'fastfetch' } else { $null }

#================================================================================
# Dependency Validation System
#================================================================================

function Validate-Dependencies {
    $requiredCommands = @('oh-my-posh', 'zoxide', 'fzf', 'rg', 'fastfetch', 'nvim', 'fd')
    $requiredModules = @('Terminal-Icons', 'winwal', 'PSFzf')

    $missingCommands = $requiredCommands | Where-Object { -not (Test-CommandExists $_) }
    $missingModules = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }

    if ($missingCommands -or $missingModules) {
        Write-Host "Missing dependencies:" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        if ($missingCommands) { Write-Host "  Commands: $($missingCommands -join ', ')" -ForegroundColor (Get-ProfileColor 'UI' 'Error') }
        if ($missingModules) { Write-Host "  Modules: $($missingModules -join ', ')" -ForegroundColor (Get-ProfileColor 'UI' 'Error') }
        Write-Host "Install missing dependencies for full functionality." -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
    } else {
        Write-Host "All required dependencies are installed and available!" -ForegroundColor "Green"
    }
}

# Dependency validation lazy loading
$global:__dependency_validation_done = $false
function Initialize-DependencyValidation {
    # Lazy load dependency validation only when needed
    if ($global:__dependency_validation_done) { return }

    try {
        Validate-Dependencies
        $global:__dependency_validation_done = $true
    } catch {
        Write-Verbose "Failed to validate dependencies: $($_.Exception.Message)"
    }
}

#================================================================================
# Module Initialization
#================================================================================

# Set up lazy loading for winwal module
$global:__winwal_init_done = $false
function Initialize-Winwal {
    # Lazy load winwal module only when theme functions are first used
    if ($global:__winwal_init_done) { return }

    try {
        Import-Module winwal -ErrorAction Stop
        $global:__winwal_init_done = $true
    } catch {
        Add-ProfileWarning "Failed to import winwal module: $($_.Exception.Message)"
        Write-Host "Please ensure winwal is installed: git clone https://github.com/scaryrawr/winwal `"$($HOME)\Documents\PowerShell\Modules\winwal`"" -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    }
}

# FZF color sync lazy loading
$global:__fzf_sync_init_done = $false
function Initialize-FZFColors {
    param(
        [switch]$Silent    # Suppress success message when called with -Silent
    )
    
    # Lazy load FZF color sync only when needed
    if ($global:__fzf_sync_init_done) { return }

    try {
        if ($Silent) {
            & "$PSScriptRoot\Scripts\sync_fzf.ps1" -Silent
        } else {
            & "$PSScriptRoot\Scripts\sync_fzf.ps1"
        }
        $global:__fzf_sync_init_done = $true
    } catch {
        Write-Verbose "Failed to sync FZF colors: $($_.Exception.Message)"
    }
}

# FD color sync lazy loading
$global:__fd_sync_init_done = $false
function Initialize-FDColors {
    param(
        [switch]$Silent    # Suppress success message when called from Initialize-PSFZF
    )
    
    # Lazy load FD color sync only when needed
    if ($global:__fd_sync_init_done) { return }

    try {
        if ($Silent) {
            & "$PSScriptRoot\Scripts\sync_fd.ps1" -Silent
        } else {
            & "$PSScriptRoot\Scripts\sync_fd.ps1"
        }
        $global:__fd_sync_init_done = $true
    } catch {
        Write-Verbose "Failed to sync FD colors: $($_.Exception.Message)"
    }
}
#endregion

#region Color & Theme System
#================================================================================
# DYNAMIC COLOR MANAGEMENT - Pywal integration and color utilities
#================================================================================

#================================================================================
# Color Helper Functions
#================================================================================

function Get-ProfileColor {
    param(
        [string]$Category,
        [string]$Name
    )

    if ($global:PSColors.ContainsKey($Category) -and
        $global:PSColors[$Category].ContainsKey($Name)) {
        return $global:PSColors[$Category][$Name]
    }

    # Return default color if not found
    return 'White'
}


#================================================================================
# Pywal Color Integration
#================================================================================
# Functions to integrate pywal colors with PSReadLine syntax highlighting

function Get-PywalColors {
    # Load pywal colors from colors.json file
    param(
        [string]$ColorsPath = "$HOME\.cache\wal\colors.json"
    )

    if (-not (Test-Path -LiteralPath $ColorsPath)) {
        Write-Verbose "Pywal colors file not found at: $ColorsPath"
        return $null
    }

    try {
        # Fix JSON formatting first using centralized script
        & "$PSScriptRoot\Scripts\fix_json_formatting.ps1" -ColorsPath $ColorsPath | Out-Null

        $colorsData = Get-Content -Path $ColorsPath -Raw | ConvertFrom-Json
        return $colorsData
    } catch {
        Write-Verbose "Failed to parse pywal colors file: $($_.Exception.Message)"
        return $null
    }
}

function Set-DynamicPSColors {
    # Apply pywal colors to PSReadLine syntax highlighting
    param(
        [string]$ColorsPath = "$HOME\.cache\wal\colors.json"
    )

    $pywalColors = Get-PywalColors -ColorsPath $ColorsPath

    if ($null -eq $pywalColors) {
        Write-Verbose "Using fallback PSReadLine colors"
        return $false
    }

    try {
        # Create PSReadLine colors dictionary using configurable mapping
        $PSColors = @{}

        foreach ($token in $global:DynamicPSColors.Keys) {
            $colorKey = $global:DynamicPSColors[$token]

            # Get the color value from pywal colors
            if ($colorKey -eq 'foreground') {
                $colorValue = $pywalColors.special.foreground
            } elseif ($colorKey -eq 'background') {
                $colorValue = $pywalColors.special.background
            } elseif ($colorKey -eq 'cursor') {
                $colorValue = $pywalColors.special.cursor
            } else {
                # Handle color0-15
                $colorValue = $pywalColors.colors.$colorKey
            }

            # Apply the color if found, otherwise use fallback
            if ($colorValue) {
                $PSColors[$token] = $colorValue
            } else {
                # Use fallback from PSColors if pywal color not found
                $PSColors[$token] = $global:PSColors.PSReadLine[$token]
                Write-Verbose "Pywal color '$colorKey' not found for token '$token', using fallback color from PSColors"
            }
        }

        # Apply the colors to PSReadLine
        Set-PSReadLineOption -Colors $PSColors

        # Update the global PSColors to maintain consistency
        $global:PSColors.PSReadLine = $PSColors

        Write-Verbose "Applied pywal colors to PSReadLine using configurable mapping"
        return $true
    } catch {
        Write-Verbose "Failed to apply pywal colors to PSReadLine: $($_.Exception.Message)"
        return $false
    }
}

function Initialize-DynamicPSColors {
    # Initialize pywal colors for PSReadLine using DynamicPSColors with PSColors fallback
    param(
        [string]$ColorsPath = "$HOME\.cache\wal\colors.json"
    )

    # Only attempt to set pywal colors if PSReadLine is available
    if (-not (Test-CommandExists Set-PSReadLineOption)) {
        Write-Verbose "PSReadLine not available, skipping pywal color initialization"
        return
    }

    $success = Set-DynamicPSColors -ColorsPath $ColorsPath

    if (-not $success) {
        Write-Verbose "Failed to load pywal colors, using PSColors.PSReadLine as fallback"
        # Ensure PSColors are applied as fallback
        try {
            Set-PSReadLineOption -Colors $global:PSColors.PSReadLine
        } catch {
            Write-Verbose "Failed to apply fallback PSColors: $($_.Exception.Message)"
        }
    }
}

#================================================================================
# Theme and Appearance Configuration
#================================================================================

# Set Oh My Posh configuration based on user preference
if ($global:OhMyPoshThemeMode -eq 'remote') {
    $ompConfig = $ompRemote
} elseif ($global:OhMyPoshThemeMode -eq 'local') {
    if ($ompLocal -and (Test-Path -LiteralPath $ompLocal)) {
        $ompConfig = $ompLocal
    } else {
        Add-ProfileWarning "Oh My Posh local theme not found at '$ompLocal'. Consider switching to 'remote' mode."
        $ompConfig = $ompRemote
    }
} else {
    Add-ProfileWarning "Invalid OhMyPoshThemeMode '$global:OhMyPoshThemeMode'. Defaulting to remote."
    $ompConfig = $ompRemote
}

# Test if Oh My Posh is installed from various sources
function Test-OhMyPoshInstalled {
    # Check if oh-my-posh command is available
    $ompCommand = Get-Command "oh-my-posh" -ErrorAction SilentlyContinue
    if ($null -eq $ompCommand) {
        return $false
    }

    # Additional checks to verify it's a complete installation
    try {
        # Test if oh-my-posh can execute (help command)
        $null = & oh-my-posh --help 2>$null
        return $true
    } catch {
        return $false
    }
}

# Lazy initialize Oh My Posh to keep shell startup fast
$global:__omp_init_done = $false
function Initialize-OhMyPosh {
    # Initialize Oh My Posh theme engine lazily to improve shell startup performance
    if ($global:__omp_init_done) { return }
    if (-not (Test-OhMyPoshInstalled)) {
        Write-Verbose "Oh My Posh not found or not properly installed. Install with winget or choco:"
        Write-Verbose "  winget: winget install JanDeDobbeleer.OhMyPosh"
        Write-Verbose "  choco:  choco install oh-my-posh"
        return
    }
    try {
        oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
        $global:__omp_init_done = $true
    } catch {
        Write-Verbose "oh-my-posh init failed: $($_.Exception.Message)"
    }
}
#endregion


#region Core Tool Integration
#================================================================================
# COMMAND LINE TOOLS - Zoxide, Editor configuration, and prompt management
#================================================================================

#================================================================================
# Zoxide Directory Jumper Configuration
#================================================================================
# Initialize zoxide for smart directory navigation and aliases
if (Test-CommandExists zoxide) {
    try {
        # =============================================================================
        # Zoxide Utility Functions
        # =============================================================================

        # Call zoxide binary, returning the output as UTF-8.
        function global:__zoxide_bin {
            $encoding = [Console]::OutputEncoding
            try {
                [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
                $result = zoxide @args
                return $result
            } finally {
                [Console]::OutputEncoding = $encoding
            }
        }

        # pwd based on zoxide's format.
        function global:__zoxide_pwd {
            $cwd = Get-Location
            if ($cwd.Provider.Name -eq "FileSystem") {
                $cwd.ProviderPath
            }
        }

        # cd + custom logic based on the value of _ZO_ECHO.
        function global:__zoxide_cd($dir, $literal) {
            $dir = if ($literal) {
                Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
            } else {
                if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
                    Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
                }
                elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
                    Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
                }
                else {
                    Set-Location -Path $dir -Passthru -ErrorAction Stop
                }
            }
        }

        # =============================================================================
        # Zoxide Hook Configuration
        # =============================================================================

        # Hook to add new entries to the database.
        $global:__zoxide_oldpwd = __zoxide_pwd
        function global:__zoxide_hook {
            $result = __zoxide_pwd
            if ($result -ne $global:__zoxide_oldpwd) {
                if ($null -ne $result) {
                    zoxide add -- $result
                }
                $global:__zoxide_oldpwd = $result
            }
        }

        # Initialize hook.
        $global:__zoxide_hooked = try {
            Get-Variable -Name __zoxide_hooked -Scope Global -ErrorAction SilentlyContinue -ValueOnly
        } catch {
            # Suppress this specific error as it doesn't affect zoxide functionality
                    # The Get-Variable error is a known PowerShell profile loading quirk that doesn't affect functionality
            $null
        }

        if ($global:__zoxide_hooked -ne 1) {
            $global:__zoxide_hooked = 1
            # Store the current prompt function before we override it
            $global:__zoxide_prompt_old = $function:prompt

            function global:prompt {
                # Call the original prompt function first
                if ($null -ne $__zoxide_prompt_old) {
                    & $__zoxide_prompt_old
                } else {
                    # Fallback prompt if original is not available
                    "[" + (Get-Location) + "] $ "
                }
                # Then call the zoxide hook to track directory changes
                $null = __zoxide_hook
            }
        }

        # =============================================================================
        # Zoxide Navigation Functions
        # =============================================================================

        # Jump to a directory using only keywords.
        function global:__zoxide_z {
            if ($args.Length -eq 0) {
                __zoxide_cd ~ $true
            }
            elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
                __zoxide_cd $args[0] $false
            }
            elseif ($args.Length -eq 1 -and (Test-Path $args[0] -PathType Container)) {
                __zoxide_cd $args[0] $true
            }
            else {
                $result = __zoxide_pwd
                if ($null -ne $result) {
                    $result = __zoxide_bin query --exclude $result -- @args
                }
                else {
                    $result = __zoxide_bin query -- @args
                }
                if ($LASTEXITCODE -eq 0) {
                    __zoxide_cd $result $true
                }
            }
        }

        # Jump to a directory using interactive search.
        # Simple implementation using zoxide's built-in fzf integration
        function global:__zoxide_zi {
            # Initialize PSFZF on first use
            Initialize-PSFZF
            $result = __zoxide_bin query -i -- @args
            if ($LASTEXITCODE -eq 0) {
                __zoxide_cd $result $true
            }
        }

        # =============================================================================
        # Zoxide Aliases
        # =============================================================================

        Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
        Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force
    } catch {
        Write-Verbose "zoxide initialization failed: $($_.Exception.Message)"
    }
} else {
    Write-Verbose "zoxide not found in PATH; skipping zoxide setup."
}

#================================================================================
# Editor Configuration
#================================================================================
# Function to get the configured editor with proper fallback handling
function Get-ConfiguredEditor {
    $editorMap = @{
        'notepad' = @('notepad')
        'neovim'  = @('nvim', 'nvim.exe')
        'vscode'  = @('code')
    }

    # Validate configured editor
    # fallback to notepad if invalid
    if ($global:DefaultEditor -notin $editorMap.Keys) {
        Add-ProfileWarning "Invalid editor '$($global:DefaultEditor)'. Using notepad."
        $global:DefaultEditor = 'notepad'
    }

    # Test configured editor commands first
    foreach ($cmd in $editorMap[$global:DefaultEditor]) {
        if (Test-CommandExists $cmd) { return $cmd }
    }

    # Fallback to any available editor
    Add-ProfileWarning "$($global:DefaultEditor) not found. Using available editor."
    return Get-FallbackEditor
}

# Helper function to provide fallback editor selection
function Get-FallbackEditor {
    $fallbackChain = @('code', 'nvim', 'nvim.exe', 'notepad')
    foreach ($editor in $fallbackChain) {
        if (Test-CommandExists $editor) { return $editor }
    }

    Add-ProfileWarning "No suitable editor found. Please install VS Code, Neovim, or ensure Notepad is available."
    return 'notepad'  # Last resort
}

# Set the EDITOR environment variable using the configured editor
$EDITOR = Get-ConfiguredEditor
Set-Alias -Name vim -Value $EDITOR -Scope Global
#endregion

#region Prompt Configuration
# Lazy initialization for prompt components to ensure fast shell startup
$global:__profile_lazy_initialized = $false

# Store the original prompt function before zoxide potentially modifies it
# FIX: Use -Scope Global and additional error handling
try {
    $promptVar = Get-Variable -Name __zoxide_prompt_old -Scope Global -ErrorAction SilentlyContinue -ValueOnly
} catch {
    # Suppress this specific error as it doesn't affect functionality
    $global:__zoxide_prompt_old = $null
}

function prompt {
    # Custom prompt with lazy initialization of UI components for fast startup
    # Run once per session to initialize optional, heavier UI components (oh-my-posh)
    if (-not $global:__profile_lazy_initialized) {
        $global:__profile_lazy_initialized = $true

        # Ensure a sensible window title immediately
        try { $Host.UI.RawUI.WindowTitle = "PowerShell $($PSVersionTable.PSVersion)" } catch {}

        # Initialize oh-my-posh if available; it may redefine prompt.
        if (Test-OhMyPoshInstalled) {
            Initialize-OhMyPosh
            # If oh-my-posh replaced the prompt function, invoke the new implementation.
            $newPromptCmd = Get-Command prompt -ErrorAction SilentlyContinue
            if ($newPromptCmd -and $newPromptCmd.CommandType -eq 'Function') {
                return & $newPromptCmd.ScriptBlock
            }
        }

        # If fastfetch wasn't available at load time, show the friendly startup message now.
        if (-not $fastfetch) {
            Write-Host "Use 'Show-Help' to list available functions." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        }
    }

    # Minimal, fast fallback prompt
    "[" + (Get-Location) + "] $ "
}
#endregion

#region PSReadLine Configuration
# Enhanced command line editing experience with colors, history, and custom key bindings
if (Test-CommandExists Set-PSReadLineOption) {
    # Initialize pywal colors for PSReadLine (will use fallback if colors.json not found)
    Initialize-DynamicPSColors

    # Configure PSReadLine with syntax highlighting colors and behavior settings
    $PSReadLineOptions = @{
        EditMode = 'Windows'
        HistoryNoDuplicates = $true
        HistorySearchCursorMovesToEnd = $true
        # Colors are now sourced from DynamicPSColors with PSColors as fallback
        Colors = $global:PSColors.PSReadLine
        PredictionSource = 'History'
        PredictionViewStyle = 'ListView'
        BellStyle = 'None'
    }
    Set-PSReadLineOption @PSReadLineOptions

    # Add prediction from both history and plugins if supported
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -MaximumHistoryCount 10000
    } catch {
        # Fallback for older PowerShell versions that don't support PredictionSource
        try {
            Set-PSReadLineOption -MaximumHistoryCount 10000
        } catch {
            Write-Verbose "PSReadLine configuration not fully supported on this PowerShell version"
        }
    }

    # Key handlers for improved navigation and editing
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
    Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

    # Security: Prevent sensitive information from being stored in history
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
        $hasSensitive = $sensitive | Where-Object { $line -match $_ }
        return ($null -eq $hasSensitive)
    }
}
#endregion

#region PSFZF Integration
# Simplified fzf integration using PSFZF module

# PSFZF lazy loading
$global:__psfzf_init_done = $false
function Initialize-PSFZF {
    # Lazy load PSFZF module only when needed
    if ($global:__psfzf_init_done) { return }

    if (-not (Get-Module -ListAvailable -Name PSFzf)) {
        Write-Host "PSFZF module not found. Install with: Install-Module -Name PSFzf -Repository PSGallery" -ForegroundColor Yellow
        return
    }

    try {
        Import-Module PSFzf -ErrorAction Stop

        # Enable default keybindings (Ctrl+t, Ctrl+r)
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

        # Initialize FZF colors first to get color scheme (silent mode)
        Initialize-FZFColors -Silent

        # Configure PSFZF with different styles for different commands
        $env:FZF_CTRL_T_OPTS = "--height 80% --layout reverse --border $env:FZF_DEFAULT_OPTS --style full --preview 'bat --color=always {}' --preview-window '~3'"

        # Set up FZF_DEFAULT_COMMAND for file searches
        if (-not $env:FZF_DEFAULT_COMMAND) {
            if (Test-CommandExists fd) {
                $env:FZF_DEFAULT_COMMAND = 'fd --hidden --follow --exclude ".git/**" --exclude "node_modules/**" --type f'
            } elseif (Test-CommandExists rg) {
                $env:FZF_DEFAULT_COMMAND = 'rg --hidden --follow --glob "!.git/**" --glob "!node_modules/**"'
            } else {
                $env:FZF_DEFAULT_COMMAND = "Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"
            }
        }

        $env:FZF_CTRL_R_OPTS = "--height 40% --reverse --border --ansi"

        # Set up zoxide to use specific options with colors from FZF_DEFAULT_OPTS
        $env:_ZO_FZF_OPTS = "--height 40% --reverse --border --ansi $env:FZF_DEFAULT_OPTS"

        $global:__psfzf_init_done = $true
    } catch {
        Write-Verbose "Failed to import PSFZF module: $($_.Exception.Message)"
    }
}

# Set up keybindings that will initialize PSFZF on first use
if (Test-CommandExists Set-PSReadLineKeyHandler) {
    # Ctrl+T for fuzzy file selection
    Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -ScriptBlock {
        Initialize-PSFZF
        # After initialization, trigger the actual PSFZF function if module loaded successfully
        if ($global:__psfzf_init_done) {
            Invoke-FuzzyZLocation
        }
    }

    # Ctrl+R for fuzzy history search
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
        Initialize-PSFZF
        # After initialization, trigger the actual PSFZF function if module loaded successfully
        if ($global:__psfzf_init_done) {
            Invoke-FuzzyHistory
        }
    }
}
#endregion

#region Basic Utilities
# Cross-platform utility functions for common operations

function touch([string]$file) { "" | Out-File $file -Encoding UTF8 -Force }

function which($name) { (Get-Command $name -EA 0 | Select-Object -First 1).Definition }

function whereis([string]$Command) {
    $env:Path -split ';' | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object {
        $base = Join-Path $_ $Command
        if (Test-Path $base) { $base }
        $env:PATHEXT -split ';' | ForEach-Object {
            $p = "$base$_"; if (Test-Path $p) { $p }
        }
    } | Sort-Object -Unique
}
#endregion

#region File System Utilities
# Enhanced file listing and navigation helpers with optional Terminal-Icons support

function Ensure-TerminalIcons {
    # Lazy-load Terminal-Icons module and ensure its format data is registered so icons show in listings.
    # Also "prime" the formatting system so subsequent ls calls show icons without requiring a prior la call.
    if ($global:__terminalicons_init) { return }

    $mod = Get-Module -ListAvailable -Name Terminal-Icons | Select-Object -First 1
    if ($null -ne $mod) {
        try {
            # Import module (force in case an older version is loaded)
            Import-Module -Name Terminal-Icons -ErrorAction Stop -Force

            # Ensure the module's format data is applied so Format-Table uses Terminal-Icons formatter
            try {
                $moduleBase = (Get-Module -Name Terminal-Icons -ErrorAction Stop).ModuleBase
                $formatFile = Join-Path $moduleBase 'Terminal-Icons.format.ps1xml'
                if (Test-Path $formatFile) {
                    # Prepend to ensure our formatter takes precedence
                    Update-FormatData -Prepend $formatFile -ErrorAction SilentlyContinue
                }
            } catch {
                Write-Verbose "Failed to register Terminal-Icons format data: $($_.Exception.Message)"
            }

            # Prime the formatting system non-interactively so ls immediately shows icons.
            try {
                # Enumerate a minimal set to trigger format system loading without producing visible output.
                Get-ChildItem -Path . -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Out-Null
            } catch {
                # ignore priming errors
            }

            $global:__terminalicons_init = $true
        } catch {
            Write-Verbose "Failed to import Terminal-Icons: $($_.Exception.Message)"
            $global:__terminalicons_init = $false
        }
    } else {
        # Module not installed; do not auto-install during normal startup
        $global:__terminalicons_init = $false
    }
}

# Directory Navigation Helpers
function mkcd([string]$dir) {
    # Create directory and change to it
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

function docs {
    # Navigate to Documents folder
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}

function dtop {
    # Navigate to Desktop folder
    Set-Location -Path ([Environment]::GetFolderPath("Desktop"))
}

# wrapper for yazi (terminal based directory navigator)
function ll {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}

# Enhanced File Listing Functions
function la {
    # List all files including hidden ones (uses Terminal-Icons when available)
    Ensure-TerminalIcons
    Get-ChildItem -Path . -Force | Format-Table -AutoSize
}

function ls {
    # Friendly 'ls' wrapper that ensures Terminal-Icons is loaded so icons show in listings.
    # Use pipeline invocation of the module formatter so it runs per-item immediately.
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )
    Ensure-TerminalIcons
    try {
        if ($Args) {
            $items = Get-ChildItem @Args -Force -ErrorAction SilentlyContinue
        } else {
            $items = Get-ChildItem -Path . -Force -ErrorAction SilentlyContinue
        }

        if ($null -eq $items) { return }

        # If Terminal-Icons formatter is available, pipe items through it (ensures per-item processing).
        if ($global:__terminalicons_init -and (Get-Command -Name 'Terminal-Icons\Format-TerminalIcons' -ErrorAction SilentlyContinue)) {
            try {
                $items | ForEach-Object { Terminal-Icons\Format-TerminalIcons $_ }
            } catch {
                $items | Format-Table -AutoSize
            }
        } else {
            # No Terminal-Icons available; normal formatted output
            $items | Format-Table -AutoSize
        }
    } catch {
        # Final fallback: raw Get-ChildItem output
        if ($Args) { Get-ChildItem @Args -Force } else { Get-ChildItem -Path . -Force }
    }
}

# Ensure the ls function takes precedence over any alias/cmdlet named 'ls' (PowerShell 7 ships an 'ls' alias).
# If an alias or cmdlet is present that would shadow this function, remove the alias and re-register the function
# in the Function: provider so subsequent calls use this implementation.
try {
    $resolved = Get-Command ls -ErrorAction SilentlyContinue
    if ($resolved -and $resolved.CommandType -ne 'Function') {
        # Remove alias if it exists (this will allow the function to be invoked)
        if (Test-Path Alias:ls) {
            Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
        }

        # Re-register function explicitly in the Function: drive to guarantee precedence
        try {
            # FIX: -Raw parameter doesn't work with Function provider, always use fallback method
            try {
                $content = Get-Content -Path Function:\ls -ErrorAction SilentlyContinue
                if ($content -is [array]) {
                    $scriptText = $content -join "`n"
                } else {
                    $scriptText = $content
                }
            } catch {
                $scriptText = $null
            }
            if ($scriptText) {
                Set-Item -Path Function:\ls -Value $scriptText -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Ignore errors re-registering function
        }
    }
} catch {
    # Non-fatal; don't block shell startup
}

#endregion

#region Additional File Utilities
# Additional file operation and text processing utilities

function nf([string]$name) {
    # Create new file in current directory
    New-Item -ItemType File -Path . -Name $name -Force | Out-Null
}

function ff([string]$pattern) {
    # Find files by name pattern recursively using fd or fallback to ripgrep/Get-ChildItem
    if (Test-CommandExists fd) {
        # Initialize FD colors for consistent theming (silent mode)
        Initialize-FDColors -Silent
        # Use fd with explicit flags and LS_COLORS for theming
        fd --hidden --follow --exclude .git --exclude node_modules --color=always $pattern
    } elseif (Test-CommandExists rg) {
        # Fallback to ripgrep if fd is not available
        rg --files --hidden --follow --glob '!.git/**' --glob '!node_modules/**' $pattern
    } else {
        # Final fallback to Get-ChildItem if neither fd nor rg is available
        Get-ChildItem -Recurse -Filter "*$pattern*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
    }
}

function unzip([string]$file) {
    # Extract zip file to current directory
    Expand-Archive -Path $file -DestinationPath $PWD -Force
}

function head([string]$Path, [int]$n=10) {
    # Show first n lines of a file
    Get-Content $Path -Head $n
}

function tail([string]$Path, [int]$n=10, [switch]$f) {
    # Show last n lines of a file with optional follow
    Get-Content $Path -Tail $n -Wait:$f
}

function grep([string]$regex, $dir) {
    # Search for regex pattern in files using ripgrep
    if (Test-CommandExists rg) {
        if ($dir) {
            rg $regex $dir
        } else {
            rg $regex
        }
    } else {
        # Fallback to Select-String if ripgrep is not available
        if ($dir) { Get-ChildItem $dir | Select-String $regex } else { $input | Select-String $regex }
    }
}

function sed([string]$file, [string]$find, [string]$replace) {
    # Replace text in a file using regex with improved error handling
    if (-not (Test-Path $file)) {
        Write-Host "File not found: $file" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        return
    }

    try {
        # Support both literal and regex patterns
        $content = Get-Content $file -Raw
        $newContent = $content -replace $find, $replace
        Set-Content $file -Value $newContent -Encoding UTF8
        Write-Host "Successfully replaced patterns in $file" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    } catch {
        Write-Host "Error processing file $file : $($_.Exception.Message)" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
    }
}

function grep-replace([string]$pattern, [string]$replace, [string]$directory = '.') {
    # Advanced find and replace using ripgrep for file discovery
    if (-not (Test-CommandExists rg)) {
        Write-Host "ripgrep (rg) not found. Install ripgrep for this functionality." -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        return
    }

    try {
        # Find files containing the pattern using ripgrep
        $files = rg --files-with-matches --hidden --follow --glob '!.git/**' --glob '!node_modules/**' $pattern $directory

        if (-not $files) {
            Write-Host "No files found containing pattern: $pattern" -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
            return
        }

        Write-Host "Found $($files.Count) files. Processing..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')

        $processed = 0
        foreach ($file in $files) {
            try {
                $content = Get-Content $file -Raw
                $newContent = $content -replace $pattern, $replace

                # Only write if content actually changed
                if ($newContent -ne $content) {
                    Set-Content $file -Value $newContent -Encoding UTF8
                    $processed++
                    Write-Host "  Updated: $file" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
                }
            } catch {
                Write-Host "  Error processing $file : $($_.Exception.Message)" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
            }
        }

        Write-Host "Completed. $processed files updated." -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    } catch {
        Write-Host "Error in grep-replace: $($_.Exception.Message)" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
    }
}
#endregion

#region Clipboard Utilities
# Clipboard operations for copy/paste functionality

function cpy([string]$text) {
    # Copy text to clipboard
    Set-Clipboard $text
}

function pst() {
    # Paste text from clipboard
    Get-Clipboard
}
#endregion

#region Git Utilities
# Git shortcuts and productivity helpers

function gs {
    # Show git status
    git status
}

function ga {
    # Add all files to staging area
    git add .
}

function gp {
    # Push changes to remote repository
    git push
}

function gcl {
    # Clone repository
    git clone $args
}

function gcom {
    # Add all files and commit with message
    git add .; git commit -m "$args"
}

function lazyg {
    # Add, commit, and push in one command
    git add .; git commit -m "$args"; git push
}
#endregion

#region System Utilities
# System maintenance and utility functions

function Update-PowerShell {
    # Update PowerShell using available package manager (prefer winget, fallback to choco)
    if (Test-CommandExists winget) {
        Write-Host "Running winget to upgrade PowerShell..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        Start-Process -FilePath winget -ArgumentList "upgrade --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements" -NoNewWindow -Wait
    } elseif (Test-CommandExists choco) {
        Write-Host "Running choco to upgrade PowerShell..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        Start-Process -FilePath choco -ArgumentList "upgrade powershell -y" -NoNewWindow -Wait
    } else {
        Add-ProfileWarning "Neither winget nor choco found. Install 'App Installer' from the Microsoft Store or Chocolatey."
        Write-Host "  winget: Install 'App Installer' from Microsoft Store, then run:"
        Write-Host "    winget upgrade --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements"
        Write-Host "  Chocolatey: https://chocolatey.org/install"
    }
}

function Edit-Profile {
    # Open the current PowerShell profile for editing using the configured editor
    param()

    $profilePath = $PROFILE

    # Ensure parent directory exists
    $parent = Split-Path -Parent $profilePath
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    # Get the configured editor with proper fallback handling
    $selectedEditor = Get-ConfiguredEditor

    try {
        # Launch the selected editor
        & $selectedEditor $profilePath
    } catch {
        Add-ProfileWarning "Failed to launch editor '$selectedEditor': $($_.Exception.Message)"

        # Try fallback editor if primary failed
        $fallbackEditor = Get-FallbackEditor
        if ($fallbackEditor -ne $selectedEditor) {
            Write-Host "Attempting fallback editor: $fallbackEditor" -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
            try {
                & $fallbackEditor $profilePath
            } catch {
                Add-ProfileWarning "Fallback editor also failed: $($_.Exception.Message)"
                Write-Host "Please manually edit your profile at: $profilePath" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
            }
        } else {
            Write-Host "Please manually edit your profile at: $profilePath" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        }
    }
}

function Reload-Profile {
    # Reload the current PowerShell profile
    try {
        . $PROFILE
    } catch {
        Add-ProfileWarning "Failed to reload profile: $($_.Exception.Message)"
    }
}

function winutil {
    # Run the WinUtil full-release script
    try { irm https://christitus.com/win | iex } catch { Add-ProfileWarning "Failed to load winutil: $($_.Exception.Message)" }
}

function winutildev {
    # Run the WinUtil pre-release script
    try { irm https://christitus.com/windev | iex } catch { Add-ProfileWarning "Failed to load winutildev: $($_.Exception.Message)" }
}

function Get-PubIP {
    # Retrieve public IP address
    try {
        $ip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()
        Write-Host "Public IP: $ip" -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    } catch {
        Add-ProfileWarning "Failed to retrieve public IP: $($_.Exception.Message)"
    }
}

function export() {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments)

    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: export KEY=value" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        return
    }

    $fullArgs = $Arguments -join ' '
    $pattern = '([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^ \t\r\n]+))'
    $matches = [regex]::Matches($fullArgs, $pattern)

    if ($matches.Count -eq 0) {
        Write-Host "Error: No valid KEY=value pairs found" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        return
    }

    foreach ($match in $matches) {
        $name = $match.Groups[1].Value
        $value = $match.Groups[2].Success ? $match.Groups[2].Value :
                 $match.Groups[3].Success ? $match.Groups[3].Value :
                 $match.Groups[4].Value

        if ($name -notmatch '^[a-zA-Z_][a-zA-Z0-9_]*$') {
            Write-Host "Error: Invalid variable name '$name'" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
            continue
        }

        try {
            [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Process)
            Write-Host "✓ Set environment variable: $name=$value" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
        } catch {
            Write-Host "Error: Failed to set '$name'" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        }
    }
}

function pkill([string]$name) {
    # Kill processes by name
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function pgrep([string]$pattern) {
    # List processes by name using regex pattern matching (inspired by ripgrep)
    try {
        Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match $pattern } | Format-Table Name, Id, CPU, WorkingSet
    } catch {
        Write-Host "Invalid regex pattern: $pattern" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        # Fallback: show all processes if regex is invalid
        Get-Process -ErrorAction SilentlyContinue | Format-Table Name, Id, CPU, WorkingSet
    }
}


function uptime {
    # Show system uptime
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "System uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" -ForegroundColor (Get-ProfileColor 'UI' 'Info')
}

function sysinfo {
    # Show computer information
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

    Write-Host "System Information:" -ForegroundColor (Get-ProfileColor 'UI' 'HelpTitle')
    Write-Host "  Computer: $($computer.Name)" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "  OS: $($os.Caption) $($os.Version)" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "  CPU: $($cpu.Name)" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "  RAM: $([math]::Round($computer.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
}

function flushdns {
    # Clear DNS cache
    try {
        Clear-DnsClientCache
        Write-Host "DNS cache cleared successfully" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    } catch {
        # Fallback for older PowerShell versions
        Start-Process -FilePath "ipconfig" -ArgumentList "/flushdns" -NoNewWindow -Wait
        Write-Host "DNS cache cleared (using ipconfig)" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    }
}
#region Theme Utilities
# Functions to update terminal themes with pywal/winwal

function update-colors {
    param(
        [Parameter(Position=0)]
        [string]$Backend,
        [Alias('b')]
        [string]$BackendAlias
    )

    # Simplified backend selection
    $backendMap = @{ '1' = $null; '2' = 'colorz'; '3' = 'colorthief'; '4' = 'haishoku' }
    $validBackends = @('default', 'colorz', 'colorthief', 'haishoku')
    $selectedBackend = if ([string]::IsNullOrEmpty($Backend) -and -not [string]::IsNullOrEmpty($BackendAlias)) { $BackendAlias } else { $Backend }

    if (-not $selectedBackend) {
        Write-Host "Select a color extraction backend:" -ForegroundColor (Get-ProfileColor 'UI' 'HelpTitle')
        Write-Host "1. Default" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
        Write-Host "2. colorz" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
        Write-Host "3. colorthief" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
        Write-Host "4. haishoku" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
        Write-Host ""

        $choice = Read-Host "Enter your choice (1-4)"
        $backendMap = @{ '1' = $null; '2' = 'colorz'; '3' = 'colorthief'; '4' = 'haishoku' }
        $backend = if ($backendMap.ContainsKey($choice)) { $backendMap[$choice] } else { $null }

        $backendNames = @{ '1' = 'Default'; '2' = 'colorz'; '3' = 'colorthief'; '4' = 'haishoku' }
        $selectedName = if ($backendNames.ContainsKey($choice)) { $backendNames[$choice] } else { 'Default' }
        Write-Host "Using $selectedName backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    } elseif ($selectedBackend -in $validBackends) {
        $backend = if ($selectedBackend -eq 'default') { $null } else { $selectedBackend }
        Write-Host "Using $(if ($backend) { $backend } else { 'default' }) backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    } else {
        Add-ProfileWarning "Invalid backend '$selectedBackend'. Using default."
        $backend = $null
        Write-Host "Using default backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    }

    # Update universal colors using pywal/winwal with selected backend
    try {
        # Sync Windows Terminal Color Scheme
        # Initialize winwal module before using theme functions
        Initialize-Winwal

        if ($backend) {
            Write-Host "Updating Windows Terminal colors scheme with $backend backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            Update-WalTheme -Backend $backend
        } else {
            Write-Host "Updating Windows Terminal colors scheme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            Update-WalTheme
        }
        Write-Host "Windows Terminal colors scheme updated successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')

        # Sync Terminal Colors for PSReadLine, PSStyle and fzf
        if (Test-CommandExists Set-PSReadLineOption) {
            try {
                # Update PSReadLine colors with new pywal/winwal theme
                Write-Host "Updating PSReadLine colors..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                Initialize-DynamicPSColors
                Write-Host "PSReadLine colors updated successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')

                # Update fzf colors to match the new pywal/winwal theme (lazy load)
                Write-Host "Updating fzf colors..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                Initialize-FZFColors
                Write-Host "fzf colors updated successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')

                # Update fd colors to match the new pywal/winwal theme (lazy load)
                Write-Host "Updating fd colors..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                Initialize-FDColors
                Write-Host "fd colors updated successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to update PSReadLine colors: $($_.Exception.Message)"
            }
        }

        # Sync Oh My Posh theme
        if (Test-OhMyPoshInstalled) {
            Write-Host "Syncing Oh My Posh theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            # Reset the initialization flag to force reinitialization
            $global:__omp_init_done = $false
            # Reinitialize Oh My Posh with the new theme
            Initialize-OhMyPosh
            Write-Host "Oh My Posh theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
        } else {
            Write-Host "Oh My Posh not found, skipping theme refresh." -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
        }

        # Sync window tiling manager theme based on global variable
        if ($global:WindowTilingManager -eq "glazewm") {
            # Sync Glazewm theme with the new color palette
            try {
                Write-Host "Syncing Glazewm theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $glazewmScript = Join-Path $PSScriptRoot "Scripts\sync_glazewm.ps1"
                & $glazewmScript
                Write-Host "Glazewm theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Glazewm theme: $($_.Exception.Message)"
            }
        }
        elseif ($global:WindowTilingManager -eq "komorebi") {
            # Sync Komorebi theme with the new color palette
            try {
                Write-Host "Syncing Komorebi theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $komorebiScript = Join-Path $PSScriptRoot "Scripts\sync_komorebi.ps1"
                & $komorebiScript
                Write-Host "Komorebi theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Komorebi theme: $($_.Exception.Message)"
            }
        }
        elseif ($global:WindowTilingManager -eq "none") {
            # No window tiling manager to sync
            Write-Host "No window tiling manager configured, skipping theme sync." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        }
        else {
            Add-ProfileWarning "Invalid WindowTilingManager value: '$($global:WindowTilingManager)'. Expected 'komorebi', 'glazewm', or 'none'."
        }

        # Sync Pywalfox theme with the new color palette (only if Pywalfox is enabled)
        if ($global:SyncPywalfox) {
            try {
                Write-Host "Syncing Pywalfox theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $pywalfoxScript = Join-Path $PSScriptRoot "Scripts\sync_pywalfox.ps1"
                & $pywalfoxScript
                Write-Host "Pywalfox theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Pywalfox theme: $($_.Exception.Message)"
            }
        }

         # Sync Discord theme with the new color palette (only if BetterDiscord is enabled)
        if ($global:SyncBetterDiscord) {
            try {
                Write-Host "Syncing Discord theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $discordScript = Join-Path $PSScriptRoot "Scripts\sync_discord.ps1"
                & $discordScript
                Write-Host "Discord theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Discord theme: $($_.Exception.Message)"
            }
        }

        # Sync Cava theme with the new color palette (only if Cava is enabled)
        if ($global:SyncCava) {
            try {
                Write-Host "Syncing Cava theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $cavaScript = Join-Path $PSScriptRoot "Scripts\sync_cava.ps1"
                & $cavaScript
                Write-Host "Cava theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Cava theme: $($_.Exception.Message)"
            }
        }

        # Sync Neovim theme with the new color palette (only if Neovim is enabled)
        if ($global:SyncNeovim) {
            try {
                Write-Host "Syncing Neovim theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $neovimScript = Join-Path $PSScriptRoot "Scripts\sync_neovim.ps1"
                & $neovimScript
                Write-Host "Neovim theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Neovim theme: $($_.Exception.Message)"
            }
        }

        # Reload yasb with the new color palette (if enabled)
        if ($global:SyncYasb) {
            try {
                Write-Host "Reloading Yasb..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                & yasbc reload
                Write-Host "Yasb reloaded successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to reload Yasb: $($_.Exception.Message)"
            }
        }

    } catch {
        Add-ProfileWarning "Failed to update colors: $($_.Exception.Message)"
    }
}

#region Help and Aliases
# Profile help system and convenient aliases

function Show-Help {
    # Display comprehensive help for all available profile functions
    $helpText = @"
$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpTitle'))PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpSeparator'))=======================$($PSStyle.Reset)

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))FILE & DIRECTORY OPERATIONS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))touch$($PSStyle.Reset) <file>     - Create or update an empty file
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))nf$($PSStyle.Reset) <name>       - Create new file in current directory
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ff$($PSStyle.Reset) <pattern>    - Find files by pattern
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))unzip$($PSStyle.Reset) <file>     - Extract zip file to current directory
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))head$($PSStyle.Reset) <file> [n]  - Show first n lines of file (default: 10)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))tail$($PSStyle.Reset) <file> [n]  - Show last n lines of file (default: 10)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))grep$($PSStyle.Reset) <regex> [dir] - Search files for regex pattern
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))sed$($PSStyle.Reset) <file> <find> <replace> - Replace text in file (regex supported)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))grep-replace$($PSStyle.Reset) <pattern> <replace> [dir] - Bulk replace across files (uses ripgrep)

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))NAVIGATION$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))mkcd$($PSStyle.Reset) <dir>       - Create directory and change to it
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))docs$($PSStyle.Reset)             - Navigate to Documents folder
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))dtop$($PSStyle.Reset)             - Navigate to Desktop folder
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ls$($PSStyle.Reset) [args]        - List files with Terminal-Icons support
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))la$($PSStyle.Reset)               - List all files including hidden
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ll$($PSStyle.Reset)               - Open Yazi file explorer

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SYSTEM UTILITIES$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))sysinfo$($PSStyle.Reset)           - Display comprehensive system information
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))uptime$($PSStyle.Reset)            - Show system uptime
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))flushdns$($PSStyle.Reset)          - Clear DNS cache
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))pkill$($PSStyle.Reset) <name>       - Kill processes by name
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))pgrep$($PSStyle.Reset) <pattern>    - List processes by regex pattern
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))export$($PSStyle.Reset) <name> <value> - Set environment variable for session

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))TOOLS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Get-PubIP$($PSStyle.Reset)        - Retrieve public IP address
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))which$($PSStyle.Reset) <name>       - Show full path of command
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))whereis$($PSStyle.Reset) <command>   - Show all locations where command is found

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))CLIPBOARD$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))cpy$($PSStyle.Reset) <text>         - Copy text to clipboard
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))pst$($PSStyle.Reset)                - Paste text from clipboard

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))GIT SHORTCUTS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))gs$($PSStyle.Reset)                 - git status
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ga$($PSStyle.Reset)                 - git add .
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))gp$($PSStyle.Reset)                 - git push
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))gcl$($PSStyle.Reset) <url>         - git clone repository
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))gcom$($PSStyle.Reset) <message>     - git add + commit with message
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))lazyg$($PSStyle.Reset) <message>     - git add + commit + push

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))PROFILE MANAGEMENT$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Edit-Profile$($PSStyle.Reset) (ep)   - Open profile in configured editor
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Reload-Profile$($PSStyle.Reset) (rp)   - Reload profile in current session
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Update-PowerShell$($PSStyle.Reset) - Update PowerShell (winget/choco)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Show-StartupDiagnostics$($PSStyle.Reset) - Display captured startup warnings/errors

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SYSTEM TOOLS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutil$($PSStyle.Reset)             - Run WinUtil full-release script
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutildev$($PSStyle.Reset)          - Run WinUtil pre-release script

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))FUZZY FINDER (FZF)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl+t$($PSStyle.Reset)             - Fuzzy file/directory selection (requires fzf)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl+r$($PSStyle.Reset)             - Fuzzy history search (requires fzf)

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SMART NAVIGATION (ZOXIDE)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Z$($PSStyle.Reset)                     - Smart directory navigation
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))zi$($PSStyle.Reset)                    - Interactive directory selection

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))THEME UTILITIES$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))update-colors$($PSStyle.Reset) [backend] - Update universal color theme following wallpaper color
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))  $([char]0x2514)$([char]0x2500)$([char]0x2500) Parameters: default, colorz, colorthief, haishoku (or no parameter for interactive menu)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))  $([char]0x2514)$([char]0x2500)$([char]0x2500) Examples: update-colors, update-colors -b colorz, update-colors -b haishoku
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))  $([char]0x2514)$([char]0x2500)$([char]0x2500) Works with: Terminal, PSReadLine, Yasb, GlazeWM, Komorebi, Better Discord, Pywalfox, Cava.

"@

    Write-Host $helpText
}

# Create short alias for Edit-Profile
Set-Alias -Name ep -Value Edit-Profile -Scope Global

# Create short alias for Reload-Profile
Set-Alias -Name rel -Value Reload-Profile -Scope Global


# ===============================================================================
# Final Startup Tasks
# ===============================================================================

# Ensure proper encoding for UTF-8 support
try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

# Clear and run fastfetch
# Only clear if ClearOnStartup is enabled
if ($global:ClearOnStartup) {
    Clear-Host
}

# Force Fastfetch to use YOUR config every time (bypass path confusion)
# Only run if window size is sufficient (minimum 60x22)
if ($global:fastfetch) {
    try {
        $windowSize = $Host.UI.RawUI.WindowSize
        $fastfetchConfig = Join-Path $HOME ".config\fastfetch\config.jsonc"
        if ($windowSize.Width -ge 60 -and $windowSize.Height -ge 22) {
            & $global:fastfetch -c $fastfetchConfig
        }
    } catch {
        # Fallback if window size detection fails
        & $global:fastfetch -c $fastfetchConfig
    }
}

# Show startup diagnostics after fastfetch if any warnings/errors were captured
$errorStart = if ($script:__profileErrorCountStart) { $script:__profileErrorCountStart } else { 0 }
if ($script:__profileWarnings.Count -gt 0 -or (($Error.Count - $errorStart) -gt 0)) {
    Show-StartupDiagnostics
}

# Set output rendering if supported (PowerShell 7.2+)
try {
    $PSStyle.OutputRendering = 'Host'
} catch {
    # Not supported in this PowerShell version
    Write-Verbose "PSStyle.OutputRendering not supported in this PowerShell version"
}

# Startup message
Write-Host "Use 'Show-Help' to list available functions." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
