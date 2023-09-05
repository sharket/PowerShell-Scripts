<#  
    .DESCRIPTION
    Remove device driver from Windows driver store.
    TIP: You can check parameters needed by running 'Get-WindowsDriver -Online -All' on a system with the driver installed, for example like this:
    Get-WindowsDriver -Online -All | where { ($_.ProviderName -like "HP") -and ($_.ClassName -like "printer") } | fl
    
    .PARAMETER Provider
    Specifies Provider attribute as shown by Get-WindowsDriver. EXAMPLE: "HP"
    
    .PARAMETER Class
    Specifies Class attribute as shown by Get-WindowsDriver. EXAMPLE: "Printer"
    
    .PARAMETER InfFile
    Specifies INF file originally used for driver installation. This is included in OriginalFileName attribute as shown by Get-WindowsDriver. EXAMPLE: "hpcu255u.inf"
    
    .PARAMETER Version
    Specifies Version attribute as shown by Get-WindowsDriver. EXAMPLE: "61.255.1.24923"
    
    .EXAMPLE
    PS> .\Remove-Driver.ps1 -Provider "HP" -Class "Printer" -InfFile "hpcu255u.inf" -Version "61.255.1.24923"
    
    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                08/08/2023
    Last Updated:           N/A
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$Provider,
    
    [Parameter(Mandatory)][string]$Class,
    
    [Parameter(Mandatory)][string]$InfFile,
    
    [Parameter(Mandatory)][string]$Version
)

##########################################
# If $env:PROCESSOR_ARCHITEW6432 exists and is set to AMD64 it means we're running 32-bit version of PowerShell
# We need to relaunch in 64-bit architecture to access pnputil.exe on 64-bit systems
If ($Env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    If ($myInvocation.Line) {
        &"$Env:windir\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }
    Else {
        &"$Env:windir\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NonInteractive -NoProfile -File "$($myInvocation.InvocationName)" -Provider $Provider -Class $Class -InfFile $InfFile -Version $Version
    }
    Exit $LastExitCode
}
# END
##########################################

$logName = "$($MyInvocation.MyCommand.Name)"
function Write-LogEntry {
    param (
        [parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message,
        
        [ValidateNotNullOrEmpty()][string]$FileName = "$logName-$env:computername.log",
        
        [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
    )
    
    # Create timestamp
    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

    # Build the log file and text
    $logFile = Join-Path -Path $env:SystemRoot -ChildPath $("Temp\$FileName")
    $logText = "$timestamp [$level] - $message"
	
    Try {
        Out-File -InputObject $logText -Append -NoClobber -Encoding Default -FilePath $logFile -ErrorAction Stop
    }
    Catch [System.Exception] {
        Write-Warning -Message "Unable to add log entry to $logFile.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Write-LogEntry -Message "#############################"
Write-LogEntry -Message "Architecture is $Env:PROCESSOR_ARCHITECTURE"
Write-LogEntry -Message "Starting: Removal of driver package from driver store"
Write-LogEntry -Message "Provider:   $Provider" 
Write-LogEntry -Message "Class:      $Class"
Write-LogEntry -Message "INF file:   $InfFile"
Write-LogEntry -Message "Version:    $Version"

# pnputil.exe expects oem#.inf which varies between systems, so we need to get that first
$driver = Get-WindowsDriver -Online -All | where {
    ($_.ProviderName -like $Provider) `
    -and ($_.ClassName -like $Class) `
    -and ($_.OriginalFileName -match $InfFile) `
    -and ($_.Version -eq $Version) `
    }

# Now remove the driver from store if it was found.
If ($driver) {
    $pnputilArgs = @(
        "/delete-driver"
        "$($driver.Driver)"
        "/force"
    )
    Try {
        Write-LogEntry -Message "Running command: Start-Process $Env:windir\System32\pnputil.exe -ArgumentList $($pnputilArgs) -Wait -PassThru"
        Start-Process $Env:windir\System32\pnputil.exe -ArgumentList $($pnputilArgs) -Wait -PassThru
        Write-LogEntry -Message "Driver removed successfully."
    }
    Catch {
        Write-LogEntry -Level ERROR -Message "Error removing driver"
        Write-LogEntry -Level ERROR -Message "$($_.Exception)"
        Exit 1
    }
}
Else {
    Write-LogEntry -Level WARN -Message "Driver NOT found."
}
