param (
    [string]$filePath
)

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
