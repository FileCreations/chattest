# Save this as ChangePermissions.ps1 in C:\Windows\System32

param (
    [string]$Path
)

# Define the log file path in the Temp directory
$logFilePath = "$env:TEMP\ChangePermissions.log"

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

        # Create the access rule
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Account, $Permissions, "None", "None", "Allow")

        # Add the access rule
        $acl.SetAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl

        Write-Log "Permissions changed successfully for '$Path'."
        Write-Host "Permissions changed successfully for '$Path'."
    } catch {
        Write-Log "An error occurred: $_"
        Write-Host "An error occurred: $_"
    }
}

function Remove-Permissions {
    param (
        [string]$Path,
        [string]$Account
    )

    try {
        $acl = Get-Acl -Path $Path

        # Remove access rules for the account
        $acl.Access | ForEach-Object {
            if ($_.IdentityReference -eq $Account) {
                $acl.RemoveAccessRule($_)
            }
        }

        Set-Acl -Path $Path -AclObject $acl

        Write-Log "Permissions removed successfully for '$Path'."
        Write-Host "Permissions removed successfully for '$Path'."
    } catch {
        Write-Log "An error occurred while removing permissions: $_"
        Write-Host "An error occurred while removing permissions: $_"
    }
}

Write-Log "Script started for '$Path'."

Write-Host "Select an action for '$Path':"
Write-Log "Prompting for action selection."

Write-Host "1. Add User Permissions"
Write-Host "2. Add Administrator Permissions"
Write-Host "3. Add System Permissions"
Write-Host "4. Add TrustedInstaller Permissions"
Write-Host "5. Add System (View Only) Permissions"
Write-Host "6. Remove User Permissions"
Write-Host "7. Remove Administrator Permissions"
Write-Host "8. Remove System Permissions"
Write-Host "9. Remove TrustedInstaller Permissions"
$selection = Read-Host "Enter the number (1-9):"

switch ($selection) {
    "1" {
        Write-Log "User selected 'Add User' permissions."
        Set-Permissions -Path $Path -Account "Users" -Permissions "FullControl"
    }
    "2" {
        Write-Log "User selected 'Add Administrator' permissions."
        Set-Permissions -Path $Path -Account "Administrators" -Permissions "FullControl"
    }
    "3" {
        Write-Log "User selected 'Add System' permissions."
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "FullControl"
    }
    "4" {
        Write-Log "User selected 'Add TrustedInstaller' permissions."
        Set-Permissions -Path $Path -Account "NT SERVICE\TrustedInstaller" -Permissions "FullControl"
    }
    "5" {
        Write-Log "User selected 'Add System (View Only)' permissions."
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "ReadAndExecute"
    }
    "6" {
        Write-Log "User selected 'Remove User' permissions."
        Remove-Permissions -Path $Path -Account "Users"
    }
    "7" {
        Write-Log "User selected 'Remove Administrator' permissions."
        Remove-Permissions -Path $Path -Account "Administrators"
    }
    "8" {
        Write-Log "User selected 'Remove System' permissions."
        Remove-Permissions -Path $Path -Account "SYSTEM"
    }
    "9" {
        Write-Log "User selected 'Remove TrustedInstaller' permissions."
        Remove-Permissions -Path $Path -Account "NT SERVICE\TrustedInstaller"
    }
    default {
        Write-Log "Invalid selection made."
        Write-Host "Invalid selection."
    }
}

Write-Log "Script finished."
Read-Host "Press Enter to exit..."
