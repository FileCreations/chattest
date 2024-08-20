param (
    [string]$filePath
)

$serviceName = 'TrustedInstaller'
$service = Get-Service -Name $serviceName -ErrorAction Stop

# Start the TrustedInstaller service if it's not running
if ($service.Status -ne 'Running') {
    Start-Service -Name $serviceName
}

# Run the selected file as TrustedInstaller
Start-Process -FilePath "psexec.exe" -ArgumentList "-accepteula -s -i \"$filePath\"" -NoNewWindow -Wait
