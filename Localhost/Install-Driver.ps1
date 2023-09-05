<#
    .DESCRIPTION
    Add .INF driver package to driver store.
    NOTE: There should be only ONE .INF file in the package!
    
    .PARAMETER InfFile
    Specifies .INF path and filename.

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                07/08/2023
    Last Updated:           N/A
#>

[CmdletBinding()]
param (
    [string]$InfFile="*.inf"
)

##########################################
# If $env:PROCESSOR_ARCHITEW6432 exists and is set to AMD64 it means we're running 32-bit version of PowerShell
# We need to relaunch in 64-bit architecture to access pnputil.exe on 64-bit systems
If ($Env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    If ($myInvocation.Line) {
        &"$Env:windir\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }
    Else {
        &"$Env:windir\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" -InfFile $InfFile
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

Try { 
    $getInfFile = Get-Item -Path $InfFile
}
Catch {
    Write-LogEntry -Level ERROR -Message "Could not find .INF file to install driver package"
    Exit 1
}

# Get driver version from .INF file
$version = Select-String -Path $InfFile -Pattern "DriverVer" | Select-Object * -First 1

Write-LogEntry -Message "#############################"
Write-LogEntry -Message "Architecture is $Env:PROCESSOR_ARCHITECTURE"
Write-LogEntry -Message "Starting: Installation of driver package"
Write-LogEntry -Message "INF file:   $($getInfFile.Name)"
Write-LogEntry -Message "Version:    $($version.Line)"

$pnputilArgs = @(
    "/add-driver"
    "$InfFile"
)

Try {
    Write-LogEntry -Message "Running command: Start-Process $Env:windir\System32\pnputil.exe -ArgumentList $($pnputilArgs) -Wait -PassThru"
    Start-Process $Env:windir\System32\pnputil.exe -ArgumentList $pnputilArgs -Wait -PassThru
    Write-LogEntry -Message "Driver installed successfully."
}
Catch {
    Write-LogEntry -Level ERROR -Message "Error adding driver"
    Write-LogEntry -Level ERROR -Message "$($_.Exception)"
    Exit 1
}
