param (
    [string]$filePath
)

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -filePath `"$filePath`"" -Verb RunAs
    exit
}

# Confirm with the user
$confirmation = Read-Host "Are you sure you want to run $filePath as TrustedInstaller? (Y/N)"
if ($confirmation -eq "Y") {
    # Run the file as TrustedInstaller using PsExec
    $psexecPath = "C:\Windows\System32\psexec.exe"
    $command = "`"$psexecPath`" -accepteula -i -s -u `NT AUTHORITY\TrustedInstaller` `"$filePath`""
    Invoke-Expression $command
} else {
    Write-Host "Operation canceled."
}

pause  # Keeps the window open to view the output and any errors
