<#
    .DESCRIPTION
    Detect built-in local admin account using well-known SID.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                28/07/2023
    Last Updated:           N/A
#>

# Set variables

$localAdmin = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount = TRUE and SID like 'S-1-5-%-500'"
$localAdminStatus = (Get-LocalUser -Name $localAdmin.Name).Enabled
$accountStatus = "unknown"
If ($localAdminStatus) { $accountStatus = "enabled" } Elseif ($localAdminStatus -eq $False) { $accountStatus = "disabled" }

Write-Output "Found local admin with S-1-5-%-500 SID, named $($localAdmin.Name) and status $accountStatus."

If ($localAdminStatus -eq $False) {
    Exit 1
}
Else {
    Exit 0
}
