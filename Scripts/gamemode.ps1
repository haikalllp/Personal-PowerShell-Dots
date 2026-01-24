param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('on','off')]
    [string]$Action
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Administrator privileges required. Restarting script with elevated permissions..." -ForegroundColor Yellow
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Action $Action"
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

function Show-Notification {
    param([string]$Title, [string]$Message)
    
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        
        $form = New-Object System.Windows.Forms.Form
        $form.ShowInTaskbar = $false
        $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
        $form.Visible = $false
        
        $balloon = New-Object System.Windows.Forms.NotifyIcon
        $balloon.Icon = $form.Icon
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $balloon.BalloonTipTitle = $Title
        $balloon.BalloonTipText = $Message
        $balloon.Visible = $true
        
        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 5500
        $timer.Add_Tick({
            $balloon.Dispose()
            $form.Close()
        })
        $timer.Start()
        
        $balloon.ShowBalloonTip(5000)
        
        [System.Windows.Forms.Application]::Run($form)
    } catch {
        Write-Host "Notification: $Title - $Message" -ForegroundColor Cyan
    }
}

$processesToKill = @(
    @{ Name = 'glazewm'; Path = 'C:\Program Files\glzr.io\GlazeWM\glazewm.exe' }
    @{ Name = 'glazewm-watcher'; Path = $null }
    @{ Name = 'yasb'; Path = 'C:\Program Files\YASB\yasb.exe' }
    @{ Name = 'PowerToys'; Path = 'C:\Program Files\PowerToys\PowerToys.exe' }
    @{ Name = 'Mechvibes'; Path = 'C:\Users\User\AppData\Local\Programs\Mechvibes\Mechvibes.exe' }
    @{ Name = 'wallpaper64'; Path = 'D:\SteamLibrary\steamapps\common\wallpaper_engine\wallpaper64.exe' }
)

if ($Action -eq 'on') {
    Write-Host "Enabling Game Mode - stopping processes..." -ForegroundColor Cyan
    
    $killedProcesses = @()
    
    foreach ($proc in $processesToKill) {
        try {
            $runningProcesses = Get-Process -Name $proc.Name -ErrorAction SilentlyContinue
            if ($runningProcesses) {
                Stop-Process -Name $proc.Name -Force -ErrorAction Stop
                $killedProcesses += $proc.Name
                Write-Host "  Stopped: $($proc.Name)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  Error stopping $($proc.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    try {
        $powerToysChildren = Get-Process -Name "PowerToys.*" -ErrorAction SilentlyContinue
        if ($powerToysChildren) {
            Stop-Process -Name "PowerToys.*" -Force -ErrorAction Stop
            Write-Host "  Stopped: PowerToys child processes" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Error stopping PowerToys children: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nGame Mode enabled. Total processes stopped: $($killedProcesses.Count)" -ForegroundColor Green
    Show-Notification -Title "Gamemode On" -Message "$($killedProcesses.Count) processes stopped for gaming"
} elseif ($Action -eq 'off') {
    Write-Host "Disabling Game Mode - restarting processes..." -ForegroundColor Cyan
    
    $restartedProcesses = @()
    
    $restartOrder = @('glazewm', 'PowerToys', 'yasb', 'Mechvibes', 'wallpaper64')
    
    foreach ($procName in $restartOrder) {
        $procInfo = $processesToKill | Where-Object { $_.Name -eq $procName }
        
        if ($procInfo -and $procInfo.Path) {
            if (Test-Path $procInfo.Path) {
                try {
                    $existingProcess = Get-Process -Name $procName -ErrorAction SilentlyContinue
                    if (-not $existingProcess) {
                        Start-Process -FilePath $procInfo.Path -ErrorAction Stop
                        $restartedProcesses += $procName
                        Write-Host "  Restarted: $($procName)" -ForegroundColor Yellow
                    } else {
                        Write-Host "  Skipped: $($procName) already running" -ForegroundColor Gray
                    }
                } catch {
                    Write-Host "  Error restarting $($procName): $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "  Skipped: $($procName) - executable not found at $($procInfo.Path)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`nGame Mode disabled. Total processes restarted: $($restartedProcesses.Count)" -ForegroundColor Green
    Show-Notification -Title "Gamemode Off" -Message "$($restartedProcesses.Count) processes restarted"
}
