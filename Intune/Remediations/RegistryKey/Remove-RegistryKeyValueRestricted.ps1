<#
    .DESCRIPTION
    Remove registry value from keys in HKCU:\SOFTWARE\Policies, which is usually restricted for editing as it should be managed by GPOs or CSPs instead.
    NOTE: Requires administrative permissions and active target user session

    .NOTES
    Version:                1.1
    Author:                 https://github.com/sharket
    Created:                28/07/2023
    Last Updated:           02/08/2023
#>

New-PSDrive HKU -PSProvider Registry -Root HKEY_USERS | Out-Null

# Get SID of currently logged in user
$userSID = (New-Object -ComObject Microsoft.DiskQuota).TranslateLogonNameToSID((Get-WmiObject -Class Win32_ComputerSystem).Username)

# Set variables
$RegistryPath = "HKU:\$userSID\SOFTWARE\Policies\Microsoft\WindowsStore"
$Name         = "RequirePrivateStoreOnly"

# Remove registry key if it exists
If (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue) {
    Try {
        Remove-ItemProperty -Path $RegistryPath -Name $Name -Force -ErrorAction Stop | Out-Null
        Write-Output "SUCCESS: $Name in $RegistryPath has been removed."
    }
    Catch {
        Write-Output "FAILED: removing item property. Error details: $_"
    }
}
Else {
    Write-Output "SKIPPED: Registry item $Name in $RegistryPath NOT found."
}
