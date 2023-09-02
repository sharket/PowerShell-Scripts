 
# Collection of PowerShell scripts

This is a collection of PowerShell scripts for various Microsoft services. Born out of need, shared with GPL love.

## Azure AD scripts:

| Script      | Description |
| ----------- | ----------- |
| [Get-UPNfromFullName.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/AzureAD/Get-UPNfromFullName.ps1) | Finds Azure AD UPN from a CSV of full names / display names |
| [Add-BulkAzureADGroupMember.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/AzureAD/Add-BulkAzureADGroupMember.ps1) | Adds multiple members to Azure AD group |

## Intune (Endpoint Manager) remediation scripts:

| Script      | Description |
| ----------- | ----------- |
| [LocalAdminAccount](https://github.com/sharket/PowerShell-Scripts/tree/main/Intune/Remediations/LocalAdminAccount) | Enables built-in administrator account based on SID |
| [PrinterPortAddress](https://github.com/sharket/PowerShell-Scripts/tree/main/Intune/Remediations/PrinterPortAddress) | Changes printer port address - IP or hostname |
| [RegistryKey](https://github.com/sharket/PowerShell-Scripts/tree/main/Intune/Remediations/RegistryKey) | Changes or removes registry key value |