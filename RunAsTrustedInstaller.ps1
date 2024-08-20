param (
    [string]$filePath
)

# Prompt the user for confirmation
$confirmation = Read-Host "Are you sure you want to run $filePath as TrustedInstaller? (Y/N)"
if ($confirmation -eq "Y") {
    $serviceName = 'TrustedInstaller'
    $service = Get-Service -Name $serviceName -ErrorAction Stop

    # Start the TrustedInstaller service if it's not running
    if ($service.Status -ne 'Running') {
        Start-Service -Name $serviceName
    }

    # Run the selected file as TrustedInstaller
    Start-Process -FilePath "psexec.exe" -ArgumentList "-accepteula -s -i \"$filePath\"" -NoNewWindow -Wait
} else {
    Write-Host "Operation canceled."
}

pause  # Keeps the window open to view the output
