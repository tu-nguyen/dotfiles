# This PowerShell script applies a series of registry tweaks to improve PC performance
# for both gaming and general use.
# It is designed to be run from WSL using a PowerShell command with administrator privileges.

# --- General Tweaks ---

# --- 1. Disable "Shortcut" Arrow on Icons
# Removes the small arrow overlay from shortcut icons on the desktop and in explorer.
Write-Host "Disabling the 'shortcut' arrow on icons.."
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}
New-ItemProperty -Path $path -Name "29" -Value "%windir%\System32\shell32.dll,50" -Type String -Force

# --- 2. Speed up PC shutdown time
# Reduces the wait time for hung processes to close on shutdown.
Write-Host "Speeding up shutdown.."
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value 5000 -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value 1000 -Type String -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Value 5000 -Type String -Force

# --- 3. Disable automatic reboot after Windows Updates
# Prevents the PC from automatically restarting after an update.
Write-Host "Disabling automatic reboot for updates.."
$auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path -Path $auPath)) {
    New-Item -Path $auPath -Force | Out-Null
}
Set-ItemProperty -Path $auPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWORD -Force

# --- Gaming Tweaks ---

# --- 1. Disable Windows Game DVR and Game Bar ---
# Game DVR can consume system resources for background recording.
# Disabling it can free up resources for games.

Write-Host "Disabling Game DVR.."
reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f

# --- 2. Disable Game Mode ---
# Game Mode is intended to optimize performance but can sometimes cause issues or stuttering.
# Disabling it allows you to manage process priority manually.

Write-Host "Disabling Game Mode.."
reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f

# --- 3. Disable Nagle's Algorithm and Optimize TCP ---
# Nagle's algorithm bundles small packets of data, which can increase latency.
# This tweak disables it and optimizes other TCP settings for gaming.

Write-Host "Disabling Nagle's Algorithm and optimizing TCP.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpNoDelay" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f

# --- 4. Optimize TCP for Gaming
# A common tweak to reduce latency for a smoother online experience.
Write-Host "Optimizing TCP for gaming.."
# Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Tcp1323Opts" -Value 1 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DefaultTTL" -Value 64 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "GlobalMaxTcpWindowSize" -Value 65535 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Value 65534 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpMaxDupAcks" -Value 2 -Type DWORD -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPTimedWaitDelay" -Value 30 -Type DWORD -Force


# --- 5. Improve Mouse Responsiveness ---
# This tweak disables mouse acceleration, which can interfere with precise movements
# and is often preferred by gamers for consistent control.

Write-Host "Improving mouse responsiveness.."
reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d 10 /f
reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseTrails" /t REG_SZ /d 0 /f

# --- 6. Disable CPU Throttling ---
# This tweak prevents the system from reducing CPU power, ensuring consistent performance.
# It is important for laptops or systems with power-saving settings.

Write-Host "Disabling CPU Throttling.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingEnabled" /t REG_DWORD /d 0 /f

# --- 7. Disable CPU Core Parking ---
# Windows parks inactive CPU cores to save power. Disabling this can reduce latency and
# stuttering during intense gaming, but may increase power consumption and heat.

Write-Host "Disabling CPU Core Parking.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d 0 /f

# --- 8. Prioritize Games for Resource Allocation ---
# This tweak makes Windows allocate more resources (CPU, GPU, memory) to games over
# background tasks.

Write-Host "Prioritizing games.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f

# --- 9. Increase System Responsiveness ---
# Windows reserves CPU time for background tasks. Lowering this value ensures more
# CPU power goes towards gaming.

Write-Host "Increasing system responsiveness.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 10 /f

# --- 10. Decrease Pre-rendered Frames ---
# This can reduce input lag by forcing the GPU to render fewer frames in advance.
# Can cause stuttering on some systems.

Write-Host "Decreasing pre-rendered frames.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f

# --- 11. Maximize Network Performance ---
# Disables TCP Initial Retransmission Timeout and forces transfers to start instantly.

Write-Host "Maximizing network performance.."
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\MSMQ\Parameters\Tcp" /v "IRR" /t REG_DWORD /d 0 /f
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\MSMQ\Parameters\Tcp" /v "SendTimeout" /t REG_DWORD /d 0 /f

Write-Host "All registry tweaks have been applied."
# Write-Host "Press any key to close this window.."
# $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
