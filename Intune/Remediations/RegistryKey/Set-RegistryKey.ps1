<#
    .DESCRIPTION
    Set registry key value.

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
$Type         = 'DWORD'

# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
    Try {
        New-Item -Path $RegistryPath -Force | Out-Null
    }
    Catch {
        Write-Output "FAILED creating new registry key. Error details: $_"
    }
}

# Now set the value
Try {
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType $Type -Force
    Write-Output "SUCCESS - Registry key $Name in $RegistryPath has been set to value $Value."
}
Catch {
    Write-Output "FAILED setting registry key value. Error details: $_"
}
