A PowerShell utility that creates a Windows desktop shortcut for a specified PowerShell script or executable and configures the shortcut to always run with Administrator privileges.

The shortcut launches the target through powershell.exe with -ExecutionPolicy Bypass and uses a binary modification to enable the Windows Run as administrator flag.

Features
Creates a shortcut on the current user's Windows Desktop.
Supports custom shortcut names.
Validates that the target file exists before creating the shortcut.
Launches PowerShell scripts using powershell.exe.
Uses -NoExit so the PowerShell window remains open after the target script finishes.
Uses -ExecutionPolicy Bypass for the launched script.
Sets the target script's directory as the shortcut's working directory.
Uses the standard PowerShell icon.
Configures the shortcut to Run as administrator.
Reports success and errors directly in the console.
Requirements
Windows
Windows PowerShell
PowerShell access to the WScript.Shell COM object
A target PowerShell script or executable that exists on the local system

Note: The script is designed around Windows .lnk shortcut files and the Windows Shell COM interface, so it is not intended for Linux or macOS.

Usage

Run the script from PowerShell:

.\Create-Shortcut.ps1 -TargetScriptPath "C:\Scripts\MyScript.ps1"

This creates:

Desktop\Wintop.lnk

The default shortcut name is Wintop.

Custom Shortcut Name

You can specify a different shortcut name using -ShortcutName:

.\Create-Shortcut.ps1 `
    -TargetScriptPath "C:\Scripts\MyScript.ps1" `
    -ShortcutName "My Admin Script"

This creates:

Desktop\My Admin Script.lnk
Parameters
Parameter	Required	Default	Description
TargetScriptPath	Yes	—	Full path to the PowerShell script or executable to launch.
ShortcutName	No	Wintop	Name of the .lnk shortcut created on the Desktop.
TargetScriptPath

The full path to the script or executable.

Example:

-TargetScriptPath "C:\Tools\Maintenance.ps1"

The script verifies that this path exists before creating the shortcut.

ShortcutName

The name of the shortcut without the .lnk extension.

Example:

-ShortcutName "System Maintenance"

The resulting shortcut will be:

System Maintenance.lnk
How It Works

The script performs the following steps:

Validates the target

Test-Path is used to ensure that the supplied target path exists.

Determines the Desktop location

The script uses:

[Environment]::GetFolderPath("Desktop")

This avoids hard-coding the user's Desktop path.

Creates the .lnk file

Windows' WScript.Shell COM object is used to create the shortcut.

Configures PowerShell as the target

The shortcut points to:

powershell.exe

with arguments similar to:

-NoExit -ExecutionPolicy Bypass -File "C:\Scripts\MyScript.ps1"

Sets the working directory

The working directory is set to the directory containing the target script.

Sets the shortcut icon

The shortcut uses the standard PowerShell icon:

powershell.exe,0

Enables Run as administrator

After the .lnk file is created, its binary data is modified to enable the Windows Run as administrator flag.

Reports the result

A green success message is displayed when the shortcut is successfully created. Errors are displayed in red.

Example

Suppose you have:

C:\Tools\Wintop.ps1

Run:

.\Create-Shortcut.ps1 `
    -TargetScriptPath "C:\Tools\Wintop.ps1" `
    -ShortcutName "Wintop"

The script creates:

%USERPROFILE%\Desktop\Wintop.lnk

Double-clicking the shortcut launches the equivalent of:

powershell.exe -NoExit -ExecutionPolicy Bypass -File "C:\Tools\Wintop.ps1"

and the shortcut is configured to request Administrator privileges.

Security Considerations
-ExecutionPolicy Bypass

The generated shortcut uses:

-ExecutionPolicy Bypass

This allows the target script to execute without being blocked by the current PowerShell execution policy.

This does not make the target script trusted or safe. Only use this with scripts you trust and control.

Administrator Privileges

The shortcut is explicitly configured to run as Administrator.

This means the target script will have elevated privileges and can potentially modify system-wide settings, files, services, registry keys, and other protected resources.

Only create administrator shortcuts for scripts that require elevation.

Shortcut Binary Modification

The script modifies the generated .lnk file directly:

$bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
$bytes[21] = $bytes[21] -bor 0x20
[System.IO.File]::WriteAllBytes($shortcutPath, $bytes)

This relies on the Windows Shell .lnk binary format and the relevant flag being located at the expected position.

Because this is a low-level modification, it should be tested against the Windows versions and shortcut types where the script will be deployed.

Error Handling

The main operations are wrapped in a try/catch block.

For example, if the target does not exist:

Error: Target file 'C:\Scripts\Missing.ps1' does not exist.

If successful:

Shortcut created at: C:\Users\<User>\Desktop\Wintop.lnk
It will always run as Administrator.
Limitations
Windows only.
Requires the Windows Shell WScript.Shell COM object.
The shortcut is created on the Desktop of the account running the script.
The current implementation always launches the target using powershell.exe.
The shortcut is configured specifically for elevated execution.
The -ExecutionPolicy Bypass option applies to the PowerShell process launched by the shortcut.
The direct .lnk binary modification depends on Windows shortcut format details.
