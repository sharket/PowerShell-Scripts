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

# Check if the key and value exist
Try {
    $currentValue = Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction Stop
}
Catch {
    Write-Output "Registry item $Name in $RegistryPath doesn't exist."
    Exit 0
}

# Check if the key is set to expected value
If (($currentValue).$Name -eq $Value) {
    Write-Output "Registry item is set to target value: $Value"
    Exit 1
}
Else {
    Write-Output "Registry item is NOT set to $Value."
    Exit 0
}
