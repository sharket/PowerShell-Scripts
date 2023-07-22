<#
    .SYNOPSIS
    Finds Azure AD UPN from a CSV of full names

    .DESCRIPTION
    Imports a list of users from CSV file and finds their Azure AD UPN.
    Takes an optional CSV file path for input. Defaults to "users.csv" in working directory.
    CSV file should have just one column named DisplayName with first and last name, i.e. "John Smith".
    
    IMPORTANT:
    If not installed already, Azure AD module must be installed in elevated PS session before running this script:
    Install-Module AzureAD
    
    .PARAMETER InputCsv
    Specifies path to the CSV file. Defaults to .\users.csv in current working directory.
    
    .PARAMETER OutputPath
    Specifies the path for the output CSV file named "UPNfromFullName-Status-YYYY-MM-DD-TTTT.csv", showing status for each operation and their corresponding UPN (if found). Defaults to current working directory .\
    IMPORTANT: Include the trailing backslash "\", for example "C:\temp\"
    
    .PARAMETER Quiet
    Supresses redundant summaries and info logs printed to the console. Warnings and errors are still shown.
    
    .EXAMPLE
    PS> .\Get-UPNfromFullName.ps1
    
    .EXAMPLE
    PS> .\Get-UPNfromFullName.ps1 -InputCsv "C:\list_of_users.csv"
    
    .EXAMPLE
    PS> .\Get-UPNfromFullName.ps1 -InputCsv "C:\list_of_users.csv" -quiet

    .NOTES
    Version:                1.1
    Author:                 https://github.com/sharket
    Created:                21/07/2023
    Last Updated:           22/07/2023
#>

[CmdletBinding()]
param (
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

# Import the CSV file. This file should have just one 'DisplayName' column
try {
    $csv = Import-Csv -Path $InputCsv
}
catch { # Could use explicit error here instead: System.IO.FileNotFoundException
    $msg = $_
    Write-Warning "Failed to import the CSV file. Press any key to exit. Error details: $msg"
    [Console]::ReadKey('NoEcho') | Out-Null
    Exit 1
}

$SkippedUsers = @()
$CompletedUsers = @()
$i = 0

$startTime = Get-Date

$outputFile = "UPNfromFullName-Status_$(Get-Date -Format yyyy-MM-dd_HH-mm).csv"
$log = @{} | Select "DisplayName","UserPrincipalName", "Status" | Export-Csv -NoTypeInformation "$($OutputPath)$($outputFile)"
$log = Import-Csv "$($OutputPath)$($outputFile)"

# Loop through the CSV and add each user to the group
foreach ($record in $csv) {
    $name = $record.DisplayName
    $azureUser = Get-AzureADUser -Filter "DisplayName eq '$name'"
    
    $i++
    Write-Progress -Activity "Processing..." -Status "$i of $($csv.Count) - $($name)" -PercentComplete (($i / $csv.Count) * 100)
    
    if ($azureUser) {
        foreach ($foundUPN in $azureUser) {
            $CompletedUsers += $name
            $log.DisplayName = $name
            $log.UserPrincipalName = $foundUPN.UserPrincipalName
            $log.Status = "Found"
            $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
        }
    }
    else {
        $SkippedUsers += $name
        $log.DisplayName = $name
        $log.Status = "Not found, skipped"
        $log | Export-Csv -NoTypeInformation -Append "$($OutputPath)$($outputFile)"
        Write-Warning "$name not found, skipped"
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

    Write-Host -BackgroundColor Black "`n--- Total time: $(New-TimeSpan -Start $startTime -End $endTime)"
    Write-Host -BackgroundColor Black "`n--- Finished. Press any key to exit."
    [Console]::ReadKey('NoEcho') | Out-Null
}
