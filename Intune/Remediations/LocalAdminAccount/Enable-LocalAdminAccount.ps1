<#
    .DESCRIPTION
    Enable built-in local admin account.

    .NOTES
    Version:                1.1
    Author:                 https://github.com/sharket
    Created:                28/07/2023
    Last Updated:           02/08/2023
#>

$localAdmin = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount = TRUE and SID like 'S-1-5-%-500'"

Try {
    Enable-LocalUser $localAdmin.Name -ErrorAction Stop
    Write-Output "SUCCESS: Local admin account $($localAdmin.Name) enabled."
}
Catch {
    Write-Output "FAILED: enabling local admin account. Error details: $_"
}
