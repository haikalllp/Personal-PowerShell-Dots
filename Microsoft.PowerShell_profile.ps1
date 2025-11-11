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
# Optional Dependencies (auto-detected, graceful degradation if missing):
# - Oh My Posh (https://ohmyposh.dev/) - Theme engine for enhanced prompt
# - zoxide (https://github.com/ajeetdsouza/zoxide) - Smart directory navigation
# - FZF (https://github.com/junegunn/fzf) - Fuzzy finder for files/history
# - ripgrep (https://github.com/BurntSushi/ripgrep) - Fast text search for FZF
# - Terminal-Icons (PowerShell module) - File icons for enhanced ls output
# - fastfetch (https://github.com/fastfetch-cli/fastfetch) - System info display
# - nvim (https://neovim.io/) - Preferred editor for profile editing
# - Visual Studio Code - Default fallback editor
#
# Required Dependencies:
# - PowerShell 7+
# - PSReadLine (usually included with PowerShell)
#
# Optional Development Tools:
# - Git - For version control utilities
# - winget - For PowerShell updates
# - Choco - For dependencies
#
# Complete Dependencies installation command:
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco install oh-my-posh zoxide fzf ripgrep fastfetch neovim -y
# Install-Module -Name Terminal-Icons -Repository PSGallery
#================================================================================

#region Environment Setup
# Set execution policy to allow running scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Configure module paths
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\scoop\modules"
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\Documents\PowerShell\Modules"
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\Documents\WindowsPowershell\Modules"
#endregion

#region Color Configuration
# Centralized color configuration for PSStyles and PSReadLineOptions
# Modify colors here

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
    
    # Return default color if not found
    return 'White'
}
#endregion

#region Theme and Appearance
# Test if a command exists in the current environment
function Test-CommandExists {
    param($command)
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
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

# Oh My Posh configuration - prefer local theme, fallback to remote
# You can change your oh-my-posh themes here
$ompLocal   = Join-Path $env:USERPROFILE "Documents\PowerShell\Themes\1_shell.json"
$ompRemote  = "https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/1_shell.omp.json"
$ompConfig  = if (Test-Path $ompLocal) { $ompLocal } else { $ompRemote }

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
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
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
        $global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction SilentlyContinue -ValueOnly)
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
if (-not (Get-Variable __zoxide_prompt_old -ErrorAction SilentlyContinue)) {
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
        if (-not $ffCmd) {
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

    # Additional options for enhanced functionality
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -MaximumHistoryCount 10000

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

#region FZF (Fuzzy Finder) Integration
# Initialize FZF with PowerShell integration for fuzzy searching files, directories, and history
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Configure FZF default command - prefer ripgrep for speed, fallback to Get-ChildItem
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        # Use PowerShell single-quoted string so double quotes reach rg on Windows
        $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/**" --glob "!node_modules/**"'
    } else {
        $env:FZF_DEFAULT_COMMAND = "Get-ChildItem -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"
    }

    # PSReadLine integration for FZF
    if (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue) {
        # Ctrl+T: Fuzzy file search and insert path
        Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
            try {
                $selection = & fzf --height 40% --reverse --border
                if (-not [string]::IsNullOrEmpty($selection)) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection.Trim())
                }
            } catch {}
        }

        # Ctrl+R: Fuzzy history search
        Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
            try {
                $historyPath = (Get-PSReadLineOption).HistorySavePath
                if (Test-Path $historyPath) {
                    $selection = Get-Content $historyPath -ErrorAction SilentlyContinue | Where-Object { $_ -ne "" } | fzf --reverse --height 40%
                    if (-not [string]::IsNullOrEmpty($selection)) {
                        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection.Trim())
                    }
                }
            } catch {}
        }
    }

    # FZF Helper Functions
    function fzf-find {
        # Launch FZF for interactive file searching
        & fzf --height 40% --reverse --border
    }

    function fzf-cd {
        # Fuzzy directory selection and navigation
        $dir = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf --height 40% --reverse --border
        if ($dir) { Set-Location $dir.Trim() }
    }

    function fzf-history {
        # Fuzzy search through command history
        $historyPath = (Get-PSReadLineOption).HistorySavePath
        if (Test-Path $historyPath) {
            Get-Content $historyPath -ErrorAction SilentlyContinue | Where-Object { $_ -ne "" } | fzf --height 40% --reverse --border
        }
    }

    # Create aliases for FZF functions
    Set-Alias -Name fzf-find -Value fzf-find
    Set-Alias -Name fzf-cd -Value fzf-cd
    Set-Alias -Name fzf-history -Value fzf-history
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
        Write-Warning "Install-Module not available in this session."
        return
    }
    Write-Host "Installing Terminal-Icons module for CurrentUser..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    try {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
        Import-Module -Name Terminal-Icons -ErrorAction Stop
        $global:__terminalicons_init = $true
        Write-Host "Terminal-Icons installed and imported." -ForegroundColor (Get-ProfileColor 'UI' 'Success')
    } catch {
        Write-Warning "Failed to install Terminal-Icons: $($_.Exception.Message)"
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
        if (Test-Path Alias:ls) { Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue }

        # Re-register function explicitly in the Function: drive to guarantee precedence
        try {
            $scriptText = (Get-Content -Path Function:\ls -Raw -ErrorAction SilentlyContinue)
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
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Running winget to upgrade PowerShell..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        Start-Process -FilePath winget -ArgumentList "upgrade --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements" -NoNewWindow -Wait
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Running choco to upgrade PowerShell..." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
        Start-Process -FilePath choco -ArgumentList "upgrade powershell -y" -NoNewWindow -Wait
    } else {
        Write-Warning "Neither winget nor choco found. Install 'App Installer' from the Microsoft Store or Chocolatey."
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
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        & nvim $profilePath
    } elseif (Get-Command nvim.exe -ErrorAction SilentlyContinue) {
        & nvim.exe $profilePath
    } else {
        & $EDITOR $profilePath
    }
}

function winutil {
    # Run the WinUtil full-release script
    try { irm https://christitus.com/win | iex } catch { Write-Warning "Failed to load winutil: $($_.Exception.Message)" }
}

function winutildev {
    # Run the WinUtil pre-release script
    try { irm https://christitus.com/windev | iex } catch { Write-Warning "Failed to load winutildev: $($_.Exception.Message)" }
}

function Get-PubIP {
    # Retrieve public IP address
    try {
        $ip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()
        Write-Host "Public IP: $ip" -ForegroundColor (Get-ProfileColor 'UI' 'Info')
    } catch {
        Write-Warning "Failed to retrieve public IP: $($_.Exception.Message)"
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

function k9([string]$name) {
    # Quick Stop-Process helper (force kill)
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
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
#endregion


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
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))k9$($PSStyle.Reset) <name>         - Quick force-kill process
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

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SYSTEM TOOLS$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutil$($PSStyle.Reset)             - Run WinUtil full-release script
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))winutildev$($PSStyle.Reset)          - Run WinUtil pre-release script

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))FUZZY FINDER (FZF)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl + t$($PSStyle.Reset)            - Launch fzf for file selection
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Ctrl + r$($PSStyle.Reset)            - Fuzzy search command history

$($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCommand'))SMART NAVIGATION (ZOXIDE)$($PSStyle.Reset)
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))Z$($PSStyle.Reset)                     - Smart directory navigation
  $($PSStyle.Foreground.$(Get-ProfileColor 'UI' 'HelpCategory'))zi$($PSStyle.Reset)                    - Interactive directory selection

"@

    Write-Host $helpText
}

# Create short alias for Edit-Profile
Set-Alias -Name ep -Value Edit-Profile -Scope Global

# Ensure proper encoding for UTF-8 support
try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host

# Force Fastfetch to use YOUR config every time (bypass path confusion)
# Only run if window size is sufficient (minimum 80x24)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    try {
        $windowSize = $Host.UI.RawUI.WindowSize
        if ($windowSize.Width -ge 80 -and $windowSize.Height -ge 24) {
            fastfetch -c "$env:USERPROFILE\.config\fastfetch\config.jsonc"
        }
    } catch {
        # Fallback if window size detection fails
        fastfetch -c "$env:USERPROFILE\.config\fastfetch\config.jsonc"
    }
}

$PSStyle.OutputRendering = 'Host'

# Friendly startup message
Write-Host "Use 'Show-Help' to list available functions." -ForegroundColor (Get-ProfileColor 'UI' 'Info')
