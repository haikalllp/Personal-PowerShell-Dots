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
# - PSFzf (PowerShell module) - PowerShell integration for FZF
# - fd (https://github.com/sharkdp/fd) - Fast file finder for FZF integration
# - ripgrep (https://github.com/BurntSushi/ripgrep) - Fast text search for FZF
# - Terminal-Icons (PowerShell module) - File icons for enhanced ls output
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
# Install-Module -Name PSFzf -Scope CurrentUser -Force
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
# - BetterDiscord (https://betterdiscord.app/) - Themed Discord client
# - Pywalfox (https://github.com/Frewacom/pywalfox) - Firefox theme sync with pywal
#================================================================================


#region User Configurations
#================================================================================
# All user-configurable settings:

# Window Tiling Manager Configuration
# Valid values: "komorebi", "glazewm", "none"
# Only one should be active at a time
$global:WindowTilingManager = "glazewm"

# Optional Theme Sync Configuration
# Set to $true if you have the corresponding application installed and want theme sync
$global:UseYasb = $true            # Set to $true if using Yasb
$global:UseBetterDiscord = $true   # Set to $true if using BetterDiscord
$global:UsePywalfox = $true        # Set to $true if using Pywalfox

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
# Centralized colour configuration for PSStyles and PSReadLineOptions
# Modify PSReadLine colors here
$global:ProfileColors = @{
    # PSReadLine Syntax Highlighting Colors
    PSReadLine = @{
        Command = '#87CEEB'       # SkyBlue
        Parameter = '#98FB98'     # PaleGreen
        Operator = '#FFB6C1'      # LightPink
        Variable = '#DDA0DD'      # Plum
        String = '#FFDAB9'        # PeachPuff
        Number = '#B0E0E6'        # PowderBlue
        Type = '#F0E68C'          # Khaki
        Comment = '#D3D3D3'       # LightGray
        Keyword = '#8367c7'       # Violet
        Error = '#FF6347'         # Tomato
    }

    # UI Colors for various output
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


# ================================================================================
# Core Functions
# ================================================================================
# DO NOT TOUCH BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
# ================================================================================

# Startup Diagnostics System
#================================================================================
# Capture warnings during profile loading to display after fastfetch
$script:__profileWarnings = @()

function Add-ProfileWarning {
    param([string]$Message)
    $script:__profileWarnings += $Message
    Write-Warning $Message
}

function Show-StartupDiagnostics {
    # Display captured warnings and errors from profile startup
    if ($script:__profileWarnings.Count -gt 0) {
        Write-Host "`n=== Profile Startup Warnings ===" -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
        foreach ($warning in $script:__profileWarnings) {
            Write-Host "  $warning" -ForegroundColor Yellow
        }
    }

    # Show unique errors from $Error (limit to first 10)
    $uniqueErrors = @()
    $seenMessages = @{}
    $errorCount = 0

    foreach ($err in $Error) {
        if ($errorCount -ge 10) { break }
        $key = $err.Exception.Message

        # FILTER: Skip known some errors that don't affect functionality
        if ($key -match "Cannot find a variable with the name '__zoxide_hooked'") {
            continue
        }

        if (-not $seenMessages.ContainsKey($key)) {
            $seenMessages[$key] = $true
            $uniqueErrors += $err
            $errorCount++
        }
    }

    if ($uniqueErrors.Count -gt 0) {
        Write-Host "`n=== Profile Startup Errors ===" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        foreach ($err in $uniqueErrors) {
            $originInfo = if ($err.InvocationInfo.MyCommand) { " ($($err.InvocationInfo.MyCommand))" } else { "" }
            Write-Host "  $($err.Exception.Message)$originInfo" -ForegroundColor Red
        }
    }
}

# Set all module paths
$psModulesPath = Join-Path $HOME "Documents\PowerShell\Modules"
$winPSModulesPath = Join-Path $HOME "Documents\WindowsPowerShell\Modules"
$scoopModulesPath = Join-Path $HOME "scoop\modules"

# Add to PSModulePath if not already present
$currentModulePath = $env:PSModulePath -split ';'
if ($scoopModulesPath -notin $currentModulePath) {
    $env:PSModulePath = "$env:PSModulePath;$scoopModulesPath"
}
if ($psModulesPath -notin $currentModulePath) {
    $env:PSModulePath = "$env:PSModulePath;$psModulesPath"
}
if ($winPSModulesPath -notin $currentModulePath) {
    $env:PSModulePath = "$env:PSModulePath;$winPSModulesPath"
}

# Helper function to test if a command exists
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

# Validate required dependencies and provide clear error messages
function Validate-Dependencies {
    $requiredCommands = @(
        'oh-my-posh', 'zoxide', 'fzf', 'rg', 'fastfetch', 'nvim', 'fd'
    )
    $requiredModules = @(
        'Terminal-Icons', 'winwal', 'PSFzf'
    )

    $missingCommands = @()
    $missingModules = @()

    foreach ($cmd in $requiredCommands) {
        if (-not (Test-CommandExists $cmd)) {
            $missingCommands += $cmd
        }
    }

    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            $missingModules += $module
        }
    }

    if ($missingCommands.Count -gt 0 -or $missingModules.Count -gt 0) {
        Write-Host "Missing required dependencies:" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        if ($missingCommands.Count -gt 0) {
            Write-Host "  Commands: $($missingCommands -join ', ')" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        }
        if ($missingModules.Count -gt 0) {
            Write-Host "  Modules: $($missingModules -join ', ')" -ForegroundColor (Get-ProfileColor 'UI' 'Error')
        }
        Write-Host "Please install missing dependencies for full functionality." -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
    }
}

# Run dependency validation
Validate-Dependencies

# Import winwal module with error handling
try {
    Import-Module winwal -ErrorAction Stop
} catch {
    Add-ProfileWarning "Failed to import winwal module: $($_.Exception.Message)"
    Write-Host "Please ensure winwal is installed: git clone https://github.com/scaryrawr/winwal `"$($HOME)\Documents\PowerShell\Modules\winwal`"" -ForegroundColor (Get-ProfileColor 'UI' 'Info')
}

#region Helper Functions
#================================================================================

# Helper function to get colors by category and name
function Get-ProfileColor {
    param(
        [string]$Category,
        [string]$Name
    )

    if ($global:ProfileColors.ContainsKey($Category) -and
        $global:ProfileColors[$Category].ContainsKey($Name)) {
        return $global:ProfileColors[$Category][$Name]
    }

    # Return default colour if not found
    return 'White'
}
#endregion

#region Theme and Appearance

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

#region Command Line Tools

# Zoxide Directory Jumper Configuration
# Initialize zoxide for smart directory navigation and aliases
if (Test-CommandExists zoxide) {
    try {
        # =============================================================================
        #
        # Utility functions for zoxide.
        #

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
        #
        # Hook configuration for zoxide.
        #

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
        #
        # When using zoxide with --no-cmd, alias these internal functions as desired.
        #

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
            $result = __zoxide_bin query -i -- @args
            if ($LASTEXITCODE -eq 0) {
                __zoxide_cd $result $true
            }
        }

        # =============================================================================
        #
        # Commands for zoxide. Disable these using --no-cmd.
        #

        Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
        Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force
    } catch {
        Write-Verbose "zoxide initialization failed: $($_.Exception.Message)"
    }
} else {
    Write-Verbose "zoxide not found in PATH; skipping zoxide setup."
}

# Editor Configuration
# Set default editor with fallback chain: VS Code -> Notepad
$EDITOR = if (Test-CommandExists code) { 'code' } elseif (Test-CommandExists notepad) { 'notepad' } else { 'notepad' }
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
    # Configure PSReadLine with syntax highlighting colors and behavior settings
    $PSReadLineOptions = @{
        EditMode = 'Windows'
        HistoryNoDuplicates = $true
        HistorySearchCursorMovesToEnd = $true
        # Colors are now centralized in $global:ProfileColors.PSReadLine
        Colors = $global:ProfileColors.PSReadLine
        PredictionSource = 'History'
        PredictionViewStyle = 'ListView'
        BellStyle = 'None'
    }
    Set-PSReadLineOption @PSReadLineOptions

    # Additional options for enhanced functionality (with version compatibility check)
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

#region PSFzf (Fuzzy Finder) Integration
# Initialize PSFzf module for enhanced fzf integration with PowerShell

# Set consistent FZF options for all fzf invocations (including zoxide)
# This ensures zi uses the same appearance as Ctrl+t and Ctrl+r
if (-not $env:FZF_DEFAULT_OPTS) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --reverse --border --ansi'
}
# Ensure zoxide uses the same fzf options as our custom bindings
# _ZO_FZF_OPTS is used by zoxide when calling fzf interactively
if (-not $env:_ZO_FZF_OPTS) {
    $env:_ZO_FZF_OPTS = $env:FZF_DEFAULT_OPTS
}

# Check if PSFzf module is available
$psfzfAvailable = Get-Module -ListAvailable -Name PSFzf

if ($psfzfAvailable) {
    try {
        # Import PSFzf module
        Import-Module PSFzf -ErrorAction Stop

        # Set key bindings for fzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

        # Use fd as the default file searcher for fzf if available
        if (Test-CommandExists fd) {
            Set-PsFzfOption -EnableFd:$true
            # Set FZF_DEFAULT_COMMAND to use fd with appropriate options
            $env:FZF_DEFAULT_COMMAND = 'fd -a -j 4'
        }
        Write-Verbose "PSFzf module loaded successfully with key bindings: Ctrl+t (file provider), Ctrl+r (history search)"

    } catch {
        Add-ProfileWarning "Failed to import PSFzf module: $($_.Exception.Message)"
        Add-ProfileWarning "Install PSFzf with: Install-Module -Name PSFzf -Scope CurrentUser -Force"
    }
} else {
    Add-ProfileWarning "PSFzf module not found. Install with: Install-Module -Name PSFzf -Scope CurrentUser -Force"

    # Fallback to basic fzf configuration if fzf command is available but PSFzf is not
    if (Test-CommandExists fzf) {
        Add-ProfileWarning "Basic fzf command detected but PSFzf module not installed. Install PSFzf for full integration."

        # Set basic FZF_DEFAULT_COMMAND if fd is available
        if (Test-CommandExists fd) {
            $env:FZF_DEFAULT_COMMAND = 'fd -a -j 4'
        }
    }
}
#endregion

#region Basic Utilities
# Cross-platform utility functions for common operations

function touch([string]$file) {
    # Create an empty file or update timestamp if file exists
    "" | Out-File -FilePath $file -Encoding UTF8 -Force
}

function which($name) {
    # Show the full path of a command
    (Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1).Definition
}

function whereis([string]$Command) {
    # Show all locations where a command is found
    $paths = $env:Path -split ';' | Where-Object { $_ -ne '' }
    $extensions = $env:PATHEXT -split ';'
    $found = @()
    foreach ($path in $paths) {
        if (-not (Test-Path $path)) { continue }
        $base = Join-Path $path $Command
        if (Test-Path $base) { $found += $base }
        foreach ($ext in $extensions) {
            $p = "$base$ext"
            if (Test-Path $p) { $found += $p }
        }
    }
    $found | Sort-Object -Unique
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

function Install-TerminalIcons {
    # Install Terminal-Icons module for enhanced file icons
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Host "Terminal-Icons is already installed." -ForegroundColor (Get-ProfileColor 'UI' 'Warning')
        return
    }
    if (-not (Get-Command Install-Module -ErrorAction SilentlyContinue)) {
        Add-ProfileWarning "Install-Module not available in this session."
        return
    }
    Write-Host "Installing Terminal-Icons module for CurrentUser..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    try {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
        Import-Module -Name Terminal-Icons -ErrorAction Stop
        $global:__terminalicons_init = $true
        Write-Host "Terminal-Icons installed and imported." -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    } catch {
        Add-ProfileWarning "Failed to install Terminal-Icons: $($_.Exception.Message)"
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

# Enhanced File Listing Functions
function la {
    # List all files including hidden ones (uses Terminal-Icons when available)
    Ensure-TerminalIcons
    Get-ChildItem -Path . -Force | Format-Table -AutoSize
}

function ll {
    # List hidden files only (uses Terminal-Icons when available)
    Ensure-TerminalIcons
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize
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

function ff([string]$name) {
    # Find files by name pattern recursively
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
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
    # Search for regex pattern in files
    if ($dir) { Get-ChildItem $dir | Select-String $regex } else { $input | Select-String $regex }
}

function sed([string]$file, [string]$find, [string]$replace) {
    # Replace text in a file using regex
    (Get-Content $file) -replace [regex]::Escape($find), $replace | Set-Content $file
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
    # Open the current PowerShell profile for editing
    param()

    $profilePath = $PROFILE

    # Ensure parent directory exists
    $parent = Split-Path -Parent $profilePath
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    # Prefer nvim if present
    if (Test-CommandExists nvim) {
        & nvim $profilePath
    } elseif (Test-CommandExists nvim.exe) {
        & nvim.exe $profilePath
    } else {
        & $EDITOR $profilePath
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

function export([string]$name, [string]$value) {
    # Set environment variable for current session
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Process)
    Write-Host "Set environment variable: $name=$value" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
}

function pkill([string]$name) {
    # Kill processes by name
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

function pgrep([string]$name) {
    # List processes by name
    Get-Process $name -ErrorAction SilentlyContinue | Format-Table Name, Id, CPU, WorkingSet
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

function update-colours {
    # Display menu for backend selection
    Write-Host "Select a color extraction backend:" -ForegroundColor (Get-ProfileColor 'UI' 'HelpTitle')
    Write-Host "1. Default" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "2. colorz" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "3. colorthief" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host "4. haishoku" -ForegroundColor (Get-ProfileColor 'UI' 'HelpCategory')
    Write-Host ""

    $choice = Read-Host "Enter your choice (1-4)"

    # Process user selection
    $backend = $null
    switch ($choice) {
        "1" {
            Write-Host "Using default backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            $backend = $null
        }
        "2" {
            Write-Host "Using colorz backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            $backend = "colorz"
        }
        "3" {
            Write-Host "Using colorthief backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            $backend = "colorthief"
        }
        "4" {
            Write-Host "Using haishoku backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            $backend = "haishoku"
        }
        default {
            Add-ProfileWarning "Invalid choice. Using default backend..."
            $backend = $null
        }
    }

    # Update terminal colors using pywal/winwal with selected backend and refresh Oh My Posh
    try {
        if ($backend) {
            Write-Host "Updating terminal colors with $backend backend..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            Update-WalTheme -Backend $backend
        } else {
            Write-Host "Updating terminal colors..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
            Update-WalTheme
        }
        Write-Host "Terminal colors updated successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')

        # Synce Oh My Posh theme
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

        # Sync Discord theme with the new colour palette (only if BetterDiscord is enabled)
        if ($global:UseBetterDiscord) {
            try {
                Write-Host "Syncing Discord theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $discordScript = Join-Path $PSScriptRoot "Scripts\sync_discord.ps1"
                & $discordScript
                Write-Host "Discord theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Discord theme: $($_.Exception.Message)"
            }
        }

        # Sync window tiling manager theme based on global variable
        if ($global:WindowTilingManager -eq "glazewm") {
            # Sync Glazewm theme with the new colour palette
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
            # Sync Komorebi theme with the new colour palette
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

        # Sync Pywalfox theme with the new colour palette (only if Pywalfox is enabled)
        if ($global:UsePywalfox) {
            try {
                Write-Host "Syncing Pywalfox theme..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                $pywalfoxScript = Join-Path $PSScriptRoot "Scripts\sync_pywalfox.ps1"
                & $pywalfoxScript
                Write-Host "Pywalfox theme synced successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to sync Pywalfox theme: $($_.Exception.Message)"
            }
        }

        # Reload yasb with the new colour palette (if enabled)
        if ($global:UseYasb) {
            try {
                Write-Host "Reloading Yasb..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
                & yasbc reload
                Write-Host "Yasb reloaded successfully!" -ForegroundColor (Get-ProfileColor 'UI' 'Success')
            } catch {
                Add-ProfileWarning "Failed to reload Yasb: $($_.Exception.Message)"
            }
        }

    } catch {
        Add-ProfileWarning "Failed to update colours: $($_.Exception.Message)"
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
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ff$($PSStyle.Reset) <pattern>    - Recursively find files matching pattern
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))unzip$($PSStyle.Reset) <file>     - Extract zip file to current directory
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))head$($PSStyle.Reset) <file> [n]  - Show first n lines of file (default: 10)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))tail$($PSStyle.Reset) <file> [n]  - Show last n lines of file (default: 10)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))grep$($PSStyle.Reset) <regex> [dir] - Search files for regex pattern
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))sed$($PSStyle.Reset) <file> <find> <replace> - Replace text in file

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))NAVIGATION$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))mkcd$($PSStyle.Reset) <dir>       - Create directory and change to it
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))docs$($PSStyle.Reset)              - Navigate to Documents folder
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))dtop$($PSStyle.Reset)             - Navigate to Desktop folder
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))la$($PSStyle.Reset)                - List all files including hidden
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ll$($PSStyle.Reset)                - List hidden files only
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))ls$($PSStyle.Reset) [args]       - List files with Terminal-Icons support

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SYSTEM UTILITIES$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))sysinfo$($PSStyle.Reset)           - Display comprehensive system information
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))uptime$($PSStyle.Reset)            - Show system uptime
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))flushdns$($PSStyle.Reset)          - Clear DNS cache
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))pkill$($PSStyle.Reset) <name>       - Kill processes by name
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))pgrep$($PSStyle.Reset) <name>       - List processes by name with details
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
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Update-PowerShell$($PSStyle.Reset) - Update PowerShell (winget/choco)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Show-StartupDiagnostics$($PSStyle.Reset) - Display captured startup warnings/errors

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SYSTEM TOOLS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutil$($PSStyle.Reset)             - Run WinUtil full-release script
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutildev$($PSStyle.Reset)          - Run WinUtil pre-release script

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))FUZZY FINDER (PSFZF)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl+t$($PSStyle.Reset)             - Fuzzy file selection (requires PSFzf)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl+r$($PSStyle.Reset)             - Fuzzy history search (requires PSFzf)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))fd | Invoke-Fzf$($PSStyle.Reset)     - Fuzzy find files listed by fd

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SMART NAVIGATION (ZOXIDE)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Z$($PSStyle.Reset)                     - Smart directory navigation
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))zi$($PSStyle.Reset)                    - Interactive directory selection

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))THEME UTILITIES$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))update-colours$($PSStyle.Reset) - Update universal colour theme following wallpaper colour with interactive menu
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))  $([char]0x2514)$([char]0x2500)$([char]0x2500) Interactive menu to select backend: default, colorz, colorthief, haishoku
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))  $([char]0x2514)$([char]0x2500)$([char]0x2500) Works with: terminal, yasb, glazewm, komorebi, better discord, pywalfox

"@

    Write-Host $helpText
}

# Create short alias for Edit-Profile
Set-Alias -Name ep -Value Edit-Profile -Scope Global


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
if ($script:__profileWarnings.Count -gt 0 -or $Error.Count -gt 0) {
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