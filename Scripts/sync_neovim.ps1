# sync_neovim.ps1
# This script copies colors-wal.vim from wal cache to Neovim configuration directory

# Paths
$sourceFile = "$env:USERPROFILE\.cache\wal\colors-wal.vim"
$targetDir = "$env:LOCALAPPDATA\wal"
$targetFile = Join-Path $targetDir "colors-wal.vim"

# Check if source file exists
if (-not (Test-Path $sourceFile)) {
    Write-Error "Source colors-wal.vim file does not exist at: $sourceFile"
    exit 1
}

# Create target directory if it doesn't exist
if (-not (Test-Path $targetDir)) {
    try {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Host "Created directory: $targetDir"
    } catch {
        Write-Error "Failed to create directory $targetDir : $_"
        exit 1
    }
}

# Copy the colors file
try {
    Copy-Item -Path $sourceFile -Destination $targetFile -Force
    Write-Host "Copied colors-wal.vim to: $targetFile"
} catch {
    Write-Error "Failed to copy colors-wal.vim : $_"
    exit 1
}

Write-Host "Neovim colors-wal.vim updated successfully"