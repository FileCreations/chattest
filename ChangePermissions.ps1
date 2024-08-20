# Save this as ChangePermissions.ps1 in C:\Windows\System32

param (
    [string]$Path
)

# Define the log file path
$logFilePath = "C:\Windows\System32\ChangePermissions.log"

# Function to write to log
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "$timestamp - $Message"
}

function Set-Permissions {
    param (
        [string]$Path,
        [string]$Account,
        [string]$Permissions
    )

    try {
        $acl = Get-Acl -Path $Path
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Account, $Permissions, "ContainerInherit,ObjectInherit", "None", "Allow")

        $acl.SetAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl

        Write-Log "Permissions changed successfully for '$Path'."
        Write-Host "Permissions changed successfully for '$Path'."
    } catch {
        Write-Log "An error occurred: $_"
        Write-Host "An error occurred: $_"
    }
}

Write-Log "Script started for '$Path'."

Write-Host "Select the permission level for '$Path':"
Write-Log "Prompting for permission level selection."

Write-Host "1. User"
Write-Host "2. Administrator"
Write-Host "3. System"
Write-Host "4. TrustedInstaller"
Write-Host "5. System (View Only)"
$selection = Read-Host "Enter the number (1-5):"

switch ($selection) {
    "1" {
        Write-Log "User selected 'User' permissions."
        Set-Permissions -Path $Path -Account "Users" -Permissions "FullControl"
    }
    "2" {
        Write-Log "User selected 'Administrator' permissions."
        Set-Permissions -Path $Path -Account "Administrators" -Permissions "FullControl"
    }
    "3" {
        Write-Log "User selected 'System' permissions."
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "FullControl"
    }
    "4" {
        Write-Log "User selected 'TrustedInstaller' permissions."
        Set-Permissions -Path $Path -Account "NT SERVICE\TrustedInstaller" -Permissions "FullControl"
    }
    "5" {
        Write-Log "User selected 'System (View Only)' permissions."
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "ReadAndExecute"
    }
    default {
        Write-Log "Invalid selection made."
        Write-Host "Invalid selection."
    }
}

Write-Log "Script finished."
Read-Host "Press Enter to exit..."
