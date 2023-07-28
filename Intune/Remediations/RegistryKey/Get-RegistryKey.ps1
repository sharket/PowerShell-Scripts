<#
    .DESCRIPTION
    Detect registry key value.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                28/07/2023
    Last Updated:           N/A
#>

# Set variables
$RegistryPath = 'HKCU:\Control Panel\Keyboard'
$Name         = 'InitialKeyboardIndicators'
$Value        = '2'

# Check if the key exist
If (-Not (Test-Path $RegistryPath)) {
    Write-Output "Registry key $Name in $RegistryPath doesn't exist."
    Exit 1
}
# Check if the key is set to expected value
Elseif ((Get-ItemProperty -Path $RegistryPath -Name $Name).$Name -eq $Value) {
    Write-Output "Registry key is set to correct value: $Value"
    Exit 0
}
Else {
    Write-Output "Registry key is not set to $Value."
    Exit 1
}
