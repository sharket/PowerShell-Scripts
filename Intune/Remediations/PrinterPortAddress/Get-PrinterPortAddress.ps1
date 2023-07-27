<#
    .DESCRIPTION
    Detect address in printer port configuration.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                27/06/2023
    Last Updated:           N/A
#>

# Define variables
$PrinterName = "Printer_Name"
$NewPrinterHostAddress = "10.10.10.75"

Try {
    $PrinterPortName = Get-Printer -Name $PrinterName -ErrorAction Stop | Select -ExpandProperty PortName
    $PrinterHostAddress = Get-PrinterPort -Name $PrinterPortName -ErrorAction Stop | Select -ExpandProperty PrinterHostAddress
    If ($PrinterHostAddress -ne $NewPrinterHostAddress) {
        Write-Output "Wrong printer port address"
        Exit 1
    }
    Else {
        Write-Output "Correct printer port address"
        Exit 0
    }
}
Catch {
    Write-Output "Printer not detected"
    Exit 0
}
