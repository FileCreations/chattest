# Save this as AddToStartup.ps1 in C:\Windows\System32

param (
    [string]$Path
)

# Define the Startup folder path
$startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')

# Define the name of the shortcut
$shortcutName = [System.IO.Path]::GetFileNameWithoutExtension($Path) + ".lnk"

# Create the shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut([System.IO.Path]::Combine($startupFolder, $shortcutName))
$shortcut.TargetPath = $Path
$shortcut.Save()

Write-Host "Shortcut created for '$Path' in the Startup folder."
