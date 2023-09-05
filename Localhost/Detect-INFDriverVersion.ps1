<#
    .DESCRIPTION
    Detect .INF driver version.
    NOTE: Define variables in the script.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                07/08/2023
    Last Updated:           N/A
#>

$ErrorActionPreference = "SilentlyContinue"

# Define variables
$InfFile = "$Env:windir\System32\DriverStore\FileRepository\cnp60ma64.inf_amd64_8196669e7bfdfc32\cnp60ma64.inf"
$Pattern = "DriverVer"
$TargetVersion = "DriverVer=11/19/2021,2.60.0.0"

$checkedVersion = Select-String -Path $InfFile -Pattern $Pattern | Select-Object * -First 1

If ($checkedVersion.Line -eq $TargetVersion) {
    Write-Output "All OK. Installed version: $($checkedVersion.Line)"
    Exit 0
}
Elseif ($checkedVersion) {
    Write-Output "Version not as expected. Detected: $($checkedVersion.Line)"
    Exit 1
}
Else {
    Write-Output "Driver not detected"
    Exit 1
}
