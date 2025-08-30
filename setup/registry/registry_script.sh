#!/bin/bash

# This script applies a series of registry tweaks to improve gaming performance on Windows.
# It uses 'reg.exe' to modify the Windows Registry.
# Note: This script must be run as an administrator to modify HKEY_LOCAL_MACHINE keys.

# --- 1. Disable Windows Game DVR and Game Bar ---
# Game DVR can consume system resources for background recording.
# Disabling it can free up resources for games.

echo "Disabling Game DVR.."
reg.exe add "HKEY_CURRENT_USER\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f

# --- 2. Disable Game Mode ---
# Game Mode is intended to optimize performance but can sometimes cause issues or stuttering.
# Disabling it allows you to manage process priority manually.

echo "Disabling Game Mode.."
reg.exe add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f

# --- 3. Disable Nagle's Algorithm and Optimize TCP ---
# Nagle's algorithm bundles small packets of data, which can increase latency.
# This tweak disables it and optimizes other TCP settings for gaming.

echo "Disabling Nagle's Algorithm and optimizing TCP.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpNoDelay" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f

# --- 4. Improve Mouse Responsiveness ---
# This tweak disables mouse acceleration, which can interfere with precise movements
# and is often preferred by gamers for consistent control.

echo "Improving mouse responsiveness.."
reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d 10 /f
reg.exe add "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseTrails" /t REG_SZ /d 0 /f

# --- 5. Disable CPU Throttling ---
# This tweak prevents the system from reducing CPU power, ensuring consistent performance.
# It is important for laptops or systems with power-saving settings.

echo "Disabling CPU Throttling.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingEnabled" /t REG_DWORD /d 0 /f

# --- 6. Disable CPU Core Parking ---
# Windows parks inactive CPU cores to save power. Disabling this can reduce latency and
# stuttering during intense gaming, but may increase power consumption and heat.

echo "Disabling CPU Core Parking.."
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d 0 /f

# --- 7. Prioritize Games for Resource Allocation ---
# This tweak makes Windows allocate more resources (CPU, GPU, memory) to games over
# background tasks.

echo "Prioritizing games.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f

# --- 8. Increase System Responsiveness ---
# Windows reserves CPU time for background tasks. Lowering this value ensures more
# CPU power goes towards gaming.

echo "Increasing system responsiveness.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 10 /f

# --- 9. Decrease Pre-rendered Frames ---
# This can reduce input lag by forcing the GPU to render fewer frames in advance.
# Can cause stuttering on some systems.

echo "Decreasing pre-rendered frames.."
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v "MaxPreRenderedFrames" /t REG_DWORD /d 1 /f

# --- 10. Maximize Network Performance ---
# Disables TCP Initial Retransmission Timeout and forces transfers to start instantly.

echo "Maximizing network performance.."
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\MSMQ\Parameters\Tcp" /v "IRR" /t REG_DWORD /d 0 /f
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\MSMQ\Parameters\Tcp" /v "SendTimeout" /t REG_DWORD /d 0 /f
