param (
    [string]$filePath
)

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -filePath `"$filePath`"" -Verb RunAs
    exit
}

# Start the TrustedInstaller service (Windows Modules Installer) if it's not running
$serviceName = 'TrustedInstaller'
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service -and $service.Status -ne 'Running') {
    Start-Service -Name $serviceName
    Write-Host "Starting the TrustedInstaller service..."
}

# Confirm with the user
$confirmation = Read-Host "Are you sure you want to run $filePath as TrustedInstaller? (Y/N)"
if ($confirmation -eq "Y") {
    # Run the file as TrustedInstaller using PsExec
    $arguments = "-accepteula -i -s -u `NT AUTHORITY\TrustedInstaller` `"$filePath`""
    Start-Process -FilePath "psexec.exe" -ArgumentList $arguments -NoNewWindow -Wait
} else {
    Write-Host "Operation canceled."
}

pause  # Keeps the window open to view the output and any errors
