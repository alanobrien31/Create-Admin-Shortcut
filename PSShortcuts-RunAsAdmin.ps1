# Create-AdminShortcut.ps1
# This script creates a desktop shortcut to a PowerShell script and sets it to always run as Administrator.

param (
    [Parameter(Mandatory = $true)]
    [string]$TargetScriptPath,  # Full path to the script or executable
    [string]$ShortcutName = "Wintop" # Name of the shortcut
)

try {
    # Validate target file
    if (-not (Test-Path $TargetScriptPath)) {
        throw "Target file '$TargetScriptPath' does not exist."
    }

    # Get desktop path
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "$ShortcutName.lnk"

    # Create shortcut using WScript.Shell
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$TargetScriptPath`""
    $shortcut.WorkingDirectory = Split-Path $TargetScriptPath
    $shortcut.IconLocation = "powershell.exe,0"
    $shortcut.Save()

    # Enable "Run as administrator" by modifying the shortcut file's binary data
    $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
    # The 21st byte (index 20) controls the RunAs flag in the .lnk file
    $bytes[21] = $bytes[21] -bor 0x20
    [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)

    Write-Host "Shortcut created at: $shortcutPath" -ForegroundColor Green
    Write-Host "It will always run as Administrator." -ForegroundColor Green
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
