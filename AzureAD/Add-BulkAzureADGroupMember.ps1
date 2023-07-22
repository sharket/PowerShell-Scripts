<#
    .SYNOPSIS
    Adds multiple users to Azure AD group

    .DESCRIPTION
    Imports a list of users from CSV file and adds them to an Azure AD group.
    Takes a string as group name and optionally CSV file path. Defaults to "users.csv" in working directory.
    CSV file should have just one column named UserPrincipalName with valid UPNs (usually email addresses).
    
    IMPORTANT:
    If not installed already, Azure AD module must be installed in elevated PS session before running this script:
    Install-Module AzureAD
    
    .PARAMETER GroupName
    Specifies Azure AD group name.
    
    .PARAMETER InputCsv
    Specifies path to the CSV file. Defaults to .\users.csv in current working directory.
    
    .PARAMETER OutputPath
    Specifies the path for the output CSV file named "BulkAzureADGroupMember-Status-YYYY-MM-DD-TTTT.csv", showing status for each operation. Defaults to current working directory .\
    IMPORTANT: Include the trailing backslash "\", for example "C:\temp\"
    
    .PARAMETER Quiet
    Supresses redundant summaries and info logs printed to the console. Warnings and errors are still shown.
    
    .EXAMPLE
    PS> .\Add-BulkAzureADGroupMember.ps1 -GroupName "My cool Azure AD group"
    
    .EXAMPLE
    PS> .\Add-BulkAzureADGroupMember.ps1 -GroupName "My cool Azure AD group" -InputCsv "C:\list_of_users.csv"
    
    .EXAMPLE
    PS> .\Add-BulkAzureADGroupMember.ps1 -GroupName "My cool Azure AD group" -InputCsv "C:\list_of_users.csv" -quiet

    .NOTES
    Version:                1.1
    Author:                 https://github.com/sharket
    Created:                12/07/2023
    Last Updated:           22/07/2023
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$GroupName,
    
    [string]$InputCsv=".\users.csv",
    
    [string]$OutputPath=".\",
    
    [switch]$Quiet=$false
)

Clear-Host

try {
    Connect-AzureAD | Out-Null
}
catch {
    $msg = $_
    Write-Warning "Failed to connect to Azure AD. Press any key to exit. Error details: $msg"
    [Console]::ReadKey('NoEcho') | Out-Null
    Exit 1
}

$group = Get-AzureADGroup -SearchString $GroupName
if ($group -eq $null) {
    Write-Warning "Group $GroupName not found. Press any key to exit."
    [Console]::ReadKey('NoEcho') | Out-Null
    Exit 1
}

# Import the CSV file. This file should have just one 'UserPrincipalName' column
try {
    $csv = Import-Csv -Path $InputCsv
}
catch { # Could use explicit error here instead: System.IO.FileNotFoundException
    $msg = $_
    Write-Warning "Failed to import the CSV file. Press any key to exit. Error details: $msg"
    [Console]::ReadKey('NoEcho') | Out-Null
    Exit 1
}

$FailedUsers = @()
$SkippedUsers = @()
$CompletedUsers = @()
$i = 0

$startTime = Get-Date

$outputFile = "BulkAzureADGroupMember-Status_$(Get-Date -Format yyyy-MM-dd_HH-mm).csv"
$log = @{} | Select "UserPrincipalName", "Status" | Export-Csv -NoTypeInformation "$($OutputPath)$($outputFile)"
$log = Import-Csv "$($OutputPath)$($outputFile)"

# Loop through the CSV and add each user to the group
foreach ($record in $csv) {
    $upn = $record.UserPrincipalName
    $azureUser = Get-AzureADUser -Filter "userPrincipalName eq '$upn'"
    
    $i++
    Write-Progress -Activity "Processing..." -Status "$i of $($csv.Count) - $($upn)" -PercentComplete (($i / $csv.Count) * 100)
    
    if ($azureUser) {
        try {
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $azureUser.ObjectId
            $CompletedUsers += $upn
            $log.UserPrincipalName = $upn
            $log.Status = "Added"
            $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
        }
        # Catch the exception if user is already a member of that group
        catch [Microsoft.Open.AzureAD16.Client.ApiException] {
            $CompletedUsers += $upn
            $log.UserPrincipalName = $upn
            $log.Status = "Already a member"
            $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
            if ($Quiet -ne $true) { Write-Host -ForegroundColor Green "$upn is already a member" }
        }
        catch {
            $FailedUsers += $upn
            $log.UserPrincipalName = $upn
            $log.Status = "FAILED to update"
            $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
            Write-Warning "$upn user found, but FAILED to update"
        }
    }
    else {
        $SkippedUsers += $upn
        $log.UserPrincipalName = $upn
        $log.Status = "Not found, skipped"
        $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
        Write-Warning "$upn not found, skipped"
    }
}

$endTime = Get-Date

Write-Progress -Completed -Activity "Completed."
Write-Host -BackgroundColor Black "`n--- $($CompletedUsers.Count) out of $($csv.Count) processed successfully"

if ($Quiet -ne $true) {
    if ($SkippedUsers) {
        Write-Host -BackgroundColor Black "`n--- $($SkippedUsers.Count) users not found, skipped:"
        #Write-Host ($SkippedUsers -join "`n")
        Write-Output $SkippedUsers | Format-List
    }

    if ($FailedUsers) {
        Write-Host -BackgroundColor Black "`n--- $($FailedUsers.Count) users found, but FAILED to update:"
        #Write-Host ($FailedUsers -join "`n")
        Write-Output $FailedUsers | Format-List
    }

    Write-Host -BackgroundColor Black "`n--- Total time: $(New-TimeSpan -Start $startTime -End $endTime)"
    Write-Host -BackgroundColor Black "`n--- Finished. Press any key to exit."
    [Console]::ReadKey('NoEcho') | Out-Null
}
