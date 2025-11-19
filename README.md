# PowerShell Profile Configuration

A comprehensive PowerShell profile configuration that enhances the Windows command-line experience with modern tools, dynamic theming, and productivity utilities.

## Overview

This repository contains a highly customized PowerShell profile (`Microsoft.PowerShell_profile.ps1`) that integrates multiple development tools and utilities to create a powerful, visually appealing terminal environment with dynamic theming capabilities.

## Features

### 🎨 Dynamic Theming System
- **Pywal/winwal Integration**: Dynamic color theming based on wallpaper colors
- **Universal Theme Sync**: Synchronizes colors across multiple applications:
  - Windows Terminal
  - PowerShell (PSReadLine syntax highlighting and PSStyles)
  - Oh My Posh prompt theme
  - FZF fuzzy finder
  - GlazeWM window manager
  - Komorebi window manager
  - BetterDiscord
  - Pywalfox (Firefox theming)
  - YASB status bar

### 📁 Enhanced File Operations
- Custom `ls`, `la`, `ll` commands with icon support
- File creation and manipulation utilities
- Enhanced navigation helpers with zoxide and fzf integration

### ⚡ Productivity Utilities
- Git shortcuts and aliases
- System information tools
- Clipboard operations
- Process management utilities
- Network utilities

---

## Installation

### Prerequisites
- Shell - PowerShell 7+ (recommended)
- Terminal - Windows Terminal (recommended)

### Required Dependencies (Must be installed)
- **Oh My Posh**: Customizable prompt with git integration
- **Terminal-Icons**: File type icons in directory listings
- **Winwal**: Wallpaper-based theming for Windows
- **Fastfetch**: System information display tool
- **Zoxide**: Smart directory navigation with fuzzy search
- **FZF**: Fuzzy finder for files and command history
- **PSFzf**: PowerShell integration for FZF
- **fd**: Fast file finder
- **ripgrep**: Fast text search integration
- **Neovim**: Modern text editor
- **Python 3.13+**: Required for Pywal/winwal

### Installation Steps

Install the following dependencies using your preferred package manager:

#### Using Chocolatey (recommended)
```powershell
# Install Chocolatey first if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required packages
choco install oh-my-posh zoxide fzf ripgrep fastfetch neovim fd -y
```

#### Using Winget
```powershell
winget install JanDeDobbeleer.OhMyPosh
winget install ajeetdsouza.zoxide
winget install junegunn.fzf
winget install BurntSushi.ripgrep.MSVC
winget install fastfetch-cli.fastfetch
winget install neovim.neovim
winget install sharkdp.fd
```

### PowerShell Modules
```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery
Install-Module -Name PSFzf -Scope CurrentUser -Force
```

### Pywal/winwal Setup
```powershell
# Clone winwal module
git clone https://github.com/scaryrawr/winwal "$HOME\Documents\PowerShell\Modules\winwal"
rm -Path "$HOME\Documents\PowerShell\Modules\winwal\.git" -r -fo

# Install Python dependencies
winget install Python.Python.3.13
pip install pywal16 colorthief colorz haishoku

# Install ImageMagick for image processing used by winwal
winget install imagemagick.imagemagick
```

### Optional Dependencies
- **GlazeWM**: Window tiling manager
- **Komorebi**: Alternative window tiling manager
- **YASB**: Windows status bar
- **BetterDiscord**: Enhanced Discord client
- **Pywalfox**: Firefox theme sync

---

## Setup PowerShell Profile

After installing the dependencies, set up the PowerShell profile:

1. Clone or download this repository to your PowerShell profile directory:
   ```powershell
   # Step 1: Check if you have a profile and back it up if needed
   if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1.backup"
    Write-Host "Your existing PowerShell profile has been backed up to Microsoft.PowerShell_profile.ps1.backup"
   }

   # Step 2: Clone to a temporary location
   git clone https://github.com/haikalllp/Personal-PowerShell-Dots "$HOME\Documents\PowerShell-Temp"

   # Step 3: Move contents to your PowerShell directory
   Move-Item "$HOME\Documents\PowerShell-Temp\*" "$HOME\Documents\PowerShell\" -Force

   # Step 4: Remove the temporary folder
   Remove-Item "$HOME\Documents\PowerShell-Temp" -Recurse -Force
   ```

2. Head to the PowerShell profile path:
   ```powershell
   cd $HOME\Documents\PowerShell

   # open the profile with preferred editor
   code .\Microsoft.PowerShell_profile.ps1
   ```

3. Configure the profile by editing the **user configuration section** in `Microsoft.PowerShell_profile.ps1`:
   - Set your preferred default editor (notepad, neovim, vscode)
   - Set your preferred window tiling manager
   - Enable/disable optional theme sync features
   - Customize color mappings
   - > See the [Configuration](#configuration) section below for details.

4. Restart PowerShell to load the new profile after configuration.
   ```powershell
   # reload profile
   . $PROFILE
   ```

---


## Configuration

### User Configuration Options

Located at the top of `Microsoft.PowerShell_profile.ps1`:

```powershell
# Default Editor Configuration
# Valid values: "notepad", "neovim", "vscode"
# Determines which editor to use for file editing operations
$global:DefaultEditor = "vscode"

# Window Tiling Manager Configuration
# Valid values: "komorebi", "glazewm", "none"
$global:WindowTilingManager = "glazewm"

# Optional Theme Sync Configuration
$global:UseYasb = $true             # Set to $true if using Yasb
$global:UseBetterDiscord = $false   # Set to $true if using BetterDiscord
$global:UsePywalfox = $false        # Set to $true if using Pywalfox

# Startup Diagnostics Configuration
$global:ClearOnStartup = $true     # Set to $false to prevent Clear-Host during startup
```

### Oh My Posh Themes Configuration

- By default uses winwal's custom ohmyposh theme located at:
  `"$HOME\.cache\wal\posh-wal-agnoster.omp.json"`

- You can switch between:
  - `posh-wal-agnoster.omp.json`
  - `posh-wal-agnosterplus.omp.json`
  - `posh-wal-atomic.omp.json`
  - `posh-wal-clean-detailed.omp.json`
  - `posh-wal-clean.omp.json`

#### Configure Oh My Posh Theme like so:
```powershell
# Oh My Posh Theme Mode Configuration
# Valid values: "local" (use local if exists, else remote with warning), "remote" (always use remote)
$global:OhMyPoshThemeMode = "local"

# For local themes can be any custom theme in any path. Here we use cached wal theme if available.
# You can generate a winwal oh-my-posh theme with winwal:
# Update-WalTheme; . $PROFILE
$ompLocal   = Join-Path $HOME ".cache\wal\posh-wal-agnoster.omp.json"
```

```powershell
# If you want to use a remote theme from Oh My Posh repository instead
$global:OhMyPoshThemeMode = "remote"

# Set the remote Oh My Posh Theme URL
$ompRemote  = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json"
```

### Powershell Color Customization

Customize PSReadLine and PSStyles colors by modifying the `$global:DynamicPSColors` mapping in the profile.

```powershell
# This uses dynamic colors from pywal/winwal, but you can customize the color mapping here
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
    # These will be used as fallbacks if pywal/winwal colors are not available
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
```

---

## Usage

### Updating Universal Theme

Update your universal theme with dynamic colors based on your wallpaper:
```powershell
update-colours
```

This command will show:
```powershell
update-colours
Select a color extraction backend:
1. Default
2. colorz
3. colorthief
4. haishoku

Enter your choice (1-4):
```
> Choose your desired backend, each backend has its own method of extracting colors from the wallpaper.
> Meaning a slight variation in colors depending on the backend chosen, good to experiment with each to see which you prefer.

**Basically the script will perform the following actions:**
1. Extract colors from your current wallpaper
2. Update Windows Terminal color scheme
3. Sync colors to all configured applications
4. Reload affected applications to apply new colors

#### Works with:
- Windows Terminal color scheme
- PowerShell (PSReadLine/PSStyles) colors
- Oh My Posh prompt theme
- FZF theme

##### Optional Syncs with:
- GlazeWM (optional)
- Komorebi (optional)
- BetterDiscord (optional)
- Pywalfox (optional)
- YASB status bar (optional)

### Navigation

- `z <directory>` - Smart directory navigation with zoxide
- `zi` - Interactive directory selection
- `docs` - Navigate to Documents folder
- `dtop` - Navigate to Desktop folder

### File Operations

- `ls` - Enhanced file listing with icons
- `la` - List all files including hidden
- `ll` - List hidden files only
- `touch <file>` - Create empty file
- `nf <name>` - Create new file
- `ff <pattern>` - Find files by pattern

### Git Shortcuts

- `gs` - git status
- `ga` - git add .
- `gp` - git push
- `gcl <url>` - git clone
- `gcom <message>` - git add + commit
- `lazyg <message>` - git add + commit + push

### System Utilities

- `sysinfo` - Display system information
- `uptime` - Show system uptime
- `flushdns` - Clear DNS cache
- `Get-PubIP` - Get public IP address
- `Edit-Profile` (or `ep`) - Edit PowerShell profile using configured default editor

### Fuzzy Finder

- `Ctrl+t` - Fuzzy file selection
- `Ctrl+r` - Fuzzy history search

## Script Files

### Core Scripts

- [`fix_json_formatting.ps1`](Scripts/fix_json_formatting.ps1) - Fixes JSON formatting issues in pywal colors
- [`sync_fzf.ps1`](Scripts/sync_fzf.ps1) - Syncs FZF colors with pywal theme
- [`sync_discord.ps1`](Scripts/sync_discord.ps1) - Syncs BetterDiscord theme
- [`sync_glazewm.ps1`](Scripts/sync_glazewm.ps1) - Syncs GlazeWM theme
- [`sync_komorebi.ps1`](Scripts/sync_komorebi.ps1) - Syncs Komorebi theme
- [`sync_pywalfox.ps1`](Scripts/sync_pywalfox.ps1) - Syncs Pywalfox theme

## Help

Use the built-in help system to see all available commands:
```powershell
Show-Help
```

## Troubleshooting

### Common Issues

1. **Profile not loading**: Ensure PowerShell execution policy allows script execution
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Missing dependencies**: Run the dependency validation to check for missing tools
   ```powershell
   Validate-Dependencies
   ```

3. **Theme sync issues**: Check startup diagnostics for warnings
   ```powershell
   Show-StartupDiagnostics
   ```

### Performance Optimization

The profile uses lazy initialization to ensure fast startup times. Optional components are loaded only when needed.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this PowerShell configuration.

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

Created by [haikalllp](https://github.com/haikalllp)