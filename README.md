 
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

## Localhost scripts:
Intended to run locally on endpoints or used in Win32 app deployments.

| Script      | Description |
| ----------- | ----------- |
| [Run-ExeFromUserSpaceAsSystem.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/Localhost/Run-ExeFromUserSpaceAsSystem.ps1) | Runs an executable in user space (i.e. AppData) invoked from system context |
| [Install-Driver.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/Localhost/Install-Driver.ps1) | Adds .INF driver package to Driver Store |
| [Remove-Driver.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/Localhost/Remove-Driver.ps1) | Removes device driver from Driver Store forcibly (even if used) |
| [Detect-INFDriverVersion.ps1](https://github.com/sharket/PowerShell-Scripts/blob/main/Localhost/Detect-INFDriverVersion.ps1)| Detects .INF driver version installed on the system |


