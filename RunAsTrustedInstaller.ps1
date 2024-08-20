param (
    [string]$filePath
)

# Function to check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as Administrator, relaunch the script with elevated privileges
if (-not (Test-Administrator)) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -filePath `"$filePath`"" -Verb RunAs
    exit
}

try {
    # Start the TrustedInstaller service (Windows Modules Installer) if it's not running
    $serviceName = 'TrustedInstaller'
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($service -and $service.Status -ne 'Running') {
        Start-Service -Name $serviceName
        Write-Host "Starting the TrustedInstaller service..."
    }

    # Prompt the user for confirmation
    $confirmation = Read-Host "Are you sure you want to run $filePath as TrustedInstaller? (Y/N)"
    if ($confirmation -eq "Y") {
        # Run the selected file as TrustedInstaller
        Start-Process -FilePath "psexec.exe" -ArgumentList "-accepteula -s -i `"$filePath`"" -NoNewWindow -Wait
    } else {
        Write-Host "Operation canceled."
    }
}
catch {
    Write-Host "An error occurred: $_"
}
finally {
    pause  # Keeps the window open to view the output and any errors
}
