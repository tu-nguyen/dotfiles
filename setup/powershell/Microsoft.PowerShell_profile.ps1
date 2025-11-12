function Get-TT {
    <#
        .SYNOPSIS
        Outputs a list of helpful, context-specific PowerShell commands for a developer.
    #>
    Write-Host "`n-- Useful Commands --" -ForegroundColor DeepPink4

    $CommandList = @(
        [PSCustomObject]@{ Command = "Get-NetTCPConnection | Where-Object { $_.LocalPort -eq 8000 }"; Description = "Finds which process is using a specific port (e.g., Django runserver)."},
        [PSCustomObject]@{ Command = "Get-Process -Name 'python' | Stop-Process -Force"; Description = "Finds and forcefully terminates a process by name (e.g., stuck Gunicorn/Python)."},
        [PSCustomObject]@{ Command = "Get-Service -Name 'MyDjangoService'"; Description = "Checks the current status (Running/Stopped) of a specific Windows Service."},
        [PSCustomObject]@{ Command = "Restart-Service -Name 'MyDjangoService'"; Description = "Stops and restarts a Windows service (often needs Administrator rights)."},
        [PSCustomObject]@{ Command = "Test-NetConnection -ComputerName '127.0.0.1' -Port 8000"; Description = "Tests network connectivity to a host and specific port (like curl/telnet)."},
        [PSCustomObject]@{ Command = "Get-Content -Path 'C:\path\to\app.log' -Tail 10 -Wait"; Description = "Views the last 10 lines of a log file and waits for new content (like 'tail -f')."}
    )

    $MaxCommandLength = ($CommandList.Command | Measure-Object -Maximum -Property Length).Maximum + 4

    $HeaderCommand = "Command"
    $HeaderDescription = "Description"

    ($HeaderCommand.PadRight($MaxCommandLength)) | Write-Host -ForegroundColor HotPink -NoNewline
    Write-Host $HeaderDescription -ForegroundColor HotPink

    ($HeaderCommand -replace ".", "-").PadRight($MaxCommandLength) | Write-Host -ForegroundColor DarkRed -NoNewline
    ($HeaderDescription -replace ".", "-") | Write-Host -ForegroundColor DarkRed

    foreach ($Cmd in $CommandList) {
        ($Cmd.Command.PadRight($MaxCommandLength)) | Write-Host -ForegroundColor HotPink -NoNewline
        Write-Host $Cmd.Description -ForegroundColor LightPink
    }
}

Set-Alias -Name 'grep' -Value 'Select-String' -Force
New-Alias -Name "ll" -Value "ls" # not really equivalent, but at least it doesn't error out
function printenvOnPowershell {
    gci env:
}
New-Alias -Name "printenv" -Value "printenvOnPowershell"

function touchOnPowershell {
  $file = $args[0]
  if($file -eq $null) {
    throw "No filename supplied"
  }
  if(Test-Path $file){
    (Get-ChildItem $file).LastWriteTime = Get-Date
  }else{
    echo $null > $file
  }
}
function cdHome {
  cd ~
}
function cdUp {
  cd ..
}
function cdUpUp {
  cd ..
  cd ..
}
function cdUpUpUp {
  cd ..
  cd ..
  cd ..
}
New-Alias -Name "touch" -Value "touchOnPowershell"
Set-Alias -Name 'tt' -Value 'Get-TT' -Force
Set-Alias -Name 'c' -Value 'clear' -Force
Set-Alias -Name 'x' -Value 'exit' -Force
Set-Alias -Name '~' -Value 'cdHome' -Force
Set-Alias -Name '..' -Value 'cdUp' -Force
Set-Alias -Name '...' -Value 'cdUpUp' -Force
Set-Alias -Name '....' -Value 'cdUpUpUp' -Force

# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false -ErrorAction Stop

# try {
#     # If PSGallery is not registered, register it first
#     if (-not (Get-PSRepository | Where-Object { $_.Name -eq 'PSGallery' })) {
#         Register-PSRepository -Default -ErrorAction Stop
#     }
#     # Trust the repository to suppress the "Untrusted repository" prompt
#     Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
#     Write-Host "PSGallery repository is set to Trusted." -ForegroundColor Green
# }
# catch {
#     Write-Error "Failed to trust PSGallery repository. Error: $($_.Exception.Message)"
# }

# Install-Module PANSIES -AllowClobber
# Install-Module PowerLine
Import-Module PANSIES
Import-Module PowerLine
Import-Module PSReadLine

$global:prompt = @(
    { "`t" } # On the first line, right-justify
    { New-PowerLineBlock (Get-Elapsed) -ErrorBack DarkRed -ErrorFore Gray74 -Fore Gray74 -Back DeepPink4 }
    { Get-Date -Format "T" }
    { "`n" } # Start another line
    { $MyInvocation.HistoryId }
    { "&Gear;" * $NestedPromptLevel }
    { if ($pushd = (Get-Location -Stack).count) { "$([char]187)" + $pushd } }
    { New-PowerLineBlock ($pwd.Drive.Name) -Fore White -Back DeepPink4 }
    { New-PowerLineBlock (Split-Path -Path (Get-Location).Path -NoQualifier) -Fore White -Back HotPink }
)

Set-PowerLinePrompt -SetCurrentDirectory -PowerLineFont -Title {
    -join @(
        if (Test-Elevation) { "Administrator: " }
        if ($IsCoreCLR) { "pwsh - " } else { "Windows PowerShell - " }
        Convert-Path $pwd
    )
} -Colors "HotPink", "DeepPink", "MediumVioletRed", "DeepPink4", "Pink", "LightPink"
# } -Colors "SteelBlue4", "DodgerBlue3", "DeepSkyBlue2", "SkyBlue2", "SteelBlue2", "LightSkyBlue1"

# Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineOption -ContinuationPrompt '> '

echo "Microsoft.Powershell_profile.ps1 done"
