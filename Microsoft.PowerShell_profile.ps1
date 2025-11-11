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
# - PowerShell 5.1+ or PowerShell 7+
# - PSReadLine (usually included with PowerShell)
#
# Optional Development Tools:
# - w64devkit (C/C++ compiler toolchain) - For C/C++ development
# - Git - For version control utilities
# - winget - For PowerShell updates
# - Choco - for dependencies
#
# Installation commands for optional dependencies:
# - Oh My Posh: choco install oh-my-posh
# - zoxide: choco install zoxide
# - FZF: choco install fzf
# - ripgrep: choco install ripgrep
# - Terminal-Icons: Install-Module -Name Terminal-Icons -Scope CurrentUser
# - fastfetch: choco install fastfetch
# - nvim: choco install neovim
#
# Complete Dependencies installation command:
# choco install oh-my-posh zoxide fzf ripgrep fastfetch neovim -y
# Install-Module -Name Terminal-Icons -Repository PSGallery
#================================================================================

#region Environment Setup
# Configure module paths
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\scoop\modules"
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\Documents\PowerShell\Modules"
$env:PSModulePath = "$env:PSModulePath;$env:USERPROFILE\Documents\WindowsPowershell\Modules"
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
        Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
        # Create convenient aliases if zoxide provides the helper functions
        if (Get-Command __zoxide_z -ErrorAction SilentlyContinue) {
            Set-Alias -Name z -Value __zoxide_z -Scope Global -Force
        }
        if (Get-Command __zoxide_zi -ErrorAction SilentlyContinue) {
            Set-Alias -Name zi -Value __zoxide_zi -Scope Global -Force
        }
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
            Write-Host "Use 'Show-Help' to list available functions." -ForegroundColor Cyan
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
        # You can modify the colours here
        Colors = @{
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
        Write-Host "Terminal-Icons is already installed." -ForegroundColor Yellow
        return
    }
    if (-not (Get-Command Install-Module -ErrorAction SilentlyContinue)) {
        Write-Warning "Install-Module not available in this session."
        return
    }
    Write-Host "Installing Terminal-Icons module for CurrentUser..." -ForegroundColor Cyan
    try {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
        Import-Module -Name Terminal-Icons -ErrorAction Stop
        $global:__terminalicons_init = $true
        Write-Host "Terminal-Icons installed and imported." -ForegroundColor Green
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
        Write-Host "Running winget to upgrade PowerShell..." -ForegroundColor Cyan
        Start-Process -FilePath winget -ArgumentList "upgrade --id Microsoft.PowerShell -e --accept-source-agreements --accept-package-agreements" -NoNewWindow -Wait
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Running choco to upgrade PowerShell..." -ForegroundColor Cyan
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
#endregion


#region Help and Aliases
# Profile help system and convenient aliases

function Show-Help {
    # Display comprehensive help for all available profile functions
    $helpText = @"
$($PSStyle.Foreground.Cyan)PowerShell Profile Help$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)=======================$($PSStyle.Reset)

$($PSStyle.Foreground.BrightMagenta)Update-PowerShell$($PSStyle.Reset) - PowerShell updater (winget preferred, choco fallback).
$($PSStyle.Foreground.BrightMagenta)Edit-Profile (ep)$($PSStyle.Reset) - Opens the current user's profile in the configured editor.
$($PSStyle.Foreground.BrightMagenta)whereis$($PSStyle.Reset) <command> - Shows locations for the specified command.
$($PSStyle.Foreground.BrightMagenta)touch$($PSStyle.Reset) <file> - Create or update an empty file.
$($PSStyle.Foreground.BrightMagenta)nf$($PSStyle.Reset) <name> - Create new file.
$($PSStyle.Foreground.BrightMagenta)ff$($PSStyle.Reset) <pattern> - Recursively find files matching pattern.
$($PSStyle.Foreground.BrightMagenta)Get-PubIP$($PSStyle.Reset) - Retrieve public IP address.
$($PSStyle.Foreground.BrightMagenta)unzip$($PSStyle.Reset) <file> - Extract a zip file to the current directory.
$($PSStyle.Foreground.BrightMagenta)hb$($PSStyle.Reset) <file> - Upload file content to hastebin-like service (if available).
$($PSStyle.Foreground.BrightMagenta)grep$($PSStyle.Reset) <regex> [dir] - Search files for a regex.
$($PSStyle.Foreground.BrightMagenta)sed$($PSStyle.Reset) <file> <find> <replace> - Replace text in a file.
$($PSStyle.Foreground.BrightMagenta)which$($PSStyle.Reset) <name> - Full path / definition of a command.
$($PSStyle.Foreground.BrightMagenta)export$($PSStyle.Reset) <name> <value> - Set environment variable for session.

$($PSStyle.Foreground.BrightMagenta)Navigation & Files$($PSStyle.Reset)
  $($PSStyle.Foreground.Yellow)mkcd$($PSStyle.Reset) - Make directory and cd into it.
  $($PSStyle.Foreground.Yellow)docs$($PSStyle.Reset) - Go to Documents.
  $($PSStyle.Foreground.Yellow)dtop$($PSStyle.Reset) - Go to Desktop.
  $($PSStyle.Foreground.Yellow)la$($PSStyle.Reset) - List files including hidden.
  $($PSStyle.Foreground.Yellow)ll$($PSStyle.Reset) - List hidden files.
  $($PSStyle.Foreground.Yellow)ls$($PSStyle.Reset) - List files.

$($PSStyle.Foreground.BrightMagenta)Process & System$($PSStyle.Reset)
  $($PSStyle.Foreground.Yellow)pkill$($PSStyle.Reset) <name> - Kill processes by name.
  $($PSStyle.Foreground.Yellow)pgrep$($PSStyle.Reset) <name> - List processes by name.
  $($PSStyle.Foreground.Yellow)k9$($PSStyle.Reset) <name> - Quick Stop-Process helper.
  $($PSStyle.Foreground.Yellow)uptime$($PSStyle.Reset) - Show system uptime.
  $($PSStyle.Foreground.Yellow)sysinfo$($PSStyle.Reset) - Show computer info.
  $($PSStyle.Foreground.Yellow)flushdns$($PSStyle.Reset) - Clear DNS cache.

$($PSStyle.Foreground.BrightMagenta)Git short-cuts$($PSStyle.Reset)
  $($PSStyle.Foreground.Yellow)gs$($PSStyle.Reset) - git status.
  $($PSStyle.Foreground.Yellow)ga$($PSStyle.Reset) - git add .
  $($PSStyle.Foreground.Yellow)gp$($PSStyle.Reset) - git push.
  $($PSStyle.Foreground.Yellow)gcl$($PSStyle.Reset) - git clone.
  $($PSStyle.Foreground.Yellow)gcom$($PSStyle.Reset) - add + commit with message.
  $($PSStyle.Foreground.Yellow)lazyg$($PSStyle.Reset) - add + commit + push.

$($PSStyle.Foreground.BrightMagenta)Utilities$($PSStyle.Reset)
  $($PSStyle.Foreground.Yellow)$($PSStyle.Foreground.Yellow)winutil$($PSStyle.Reset), $($PSStyle.Foreground.Yellow)winutildev$($PSStyle.Reset).

$($PSStyle.Foreground.BrightMagenta)FZF Commands:$($PSStyle.Reset)
$($PSStyle.Foreground.Yellow)  Ctrl + t$($PSStyle.Reset) - Launch fzf for files.
$($PSStyle.Foreground.Yellow)  Ctrl + r$($PSStyle.Reset) - Fuzzy search history.

"@

    Write-Host $helpText
}

# Create short alias for Edit-Profile
Set-Alias -Name ep -Value Edit-Profile -Scope Global

# Minimal profile: UTF‑8 + Oh My Posh (if installed) + Fastfetch with explicit config path
try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host

# Force Fastfetch to use YOUR config every time (bypass path confusion)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "$env:USERPROFILE\.config\fastfetch\config.jsonc"
}

$PSStyle.OutputRendering = 'Host'

# Friendly startup message
Write-Host "Use 'Show-Help' to list available functions." -ForegroundColor Cyan
