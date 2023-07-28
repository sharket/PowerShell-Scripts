<#
    .DESCRIPTION
    Enable built-in local admin account.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                28/07/2023
    Last Updated:           N/A
#>

$localAdmin = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount = TRUE and SID like 'S-1-5-%-500'"

Try {
    Enable-LocalUser $localAdmin.Name
    Write-Output "SUCCESS: Local admin account $($localAdmin.Name) enabled."
}
Catch {
    Write-Output "FAILED: enabling local admin account. Error details: $_"
}
