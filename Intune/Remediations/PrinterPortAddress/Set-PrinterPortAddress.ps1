<#
    .DESCRIPTION
    Set address in printer port configuration.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                27/06/2023
    Last Updated:           N/A
#>

# Define variables
$PrinterName = "Printer_Name"
$NewPrinterPortName = "10.10.10.75"
$NewPrinterHostAddress = "10.10.10.75"

Try {
    Add-PrinterPort -Name $NewPrinterPortName -PrinterHostAddress $NewPrinterHostAddress -ErrorAction Stop
    Set-Printer -Name $PrinterName -PortName $NewPrinterPortName -ErrorAction Stop
    Write-Output "Printer config changed succesfully. New port name: $NewPrinterPortName with address: $NewPrinterHostAddress"
    Pause
    Exit 0
}
Catch {
    Write-Output "FAILED configuring printer port! $_"
    Exit 1
}
