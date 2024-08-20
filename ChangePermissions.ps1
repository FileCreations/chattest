# Save this as ChangePermissions.ps1 in C:\Windows\System32

param (
    [string]$Path
)

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

        Write-Host "Permissions changed successfully for '$Path'."
    } catch {
        Write-Host "An error occurred: $_"
    }
}

Write-Host "Select the permission level for '$Path':"
Write-Host "1. User"
Write-Host "2. Administrator"
Write-Host "3. System"
Write-Host "4. TrustedInstaller"
Write-Host "5. System (View Only)"
$selection = Read-Host "Enter the number (1-5):"

switch ($selection) {
    "1" {
        Set-Permissions -Path $Path -Account "Users" -Permissions "FullControl"
    }
    "2" {
        Set-Permissions -Path $Path -Account "Administrators" -Permissions "FullControl"
    }
    "3" {
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "FullControl"
    }
    "4" {
        Set-Permissions -Path $Path -Account "NT SERVICE\TrustedInstaller" -Permissions "FullControl"
    }
    "5" {
        Set-Permissions -Path $Path -Account "SYSTEM" -Permissions "ReadAndExecute"
    }
    default {
        Write-Host "Invalid selection."
    }
}

Read-Host "Press Enter to exit..."
