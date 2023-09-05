<#
    .DESCRIPTION
    Run an executable in user space (i.e. AppData), invoked from system context. Environment variables such as %USERNAME% and %APPDATA% do not resolve correctly when running in system context. Goal of this script is to work around that.
    DISCLAIMER: Since files in user space can be easily modified / replaced, invoking them with system level permissions is generally a bad idea.

    .PARAMETER Exe
    Path for the executable within user space, excluding C:\Users\$USERNAME%. EXAMPLE: "\AppData\Local\MicroSIP\Uninstall.exe"

    .PARAMETER Args
    Arguments to be passed. Use single quotes for strings inside.

    .EXAMPLE
    Run-ExeFromUserSpaceAsSystem -Exe "\AppData\Local\MicroSIP\Uninstall.exe" -Args "/S /v'/qn'"

    .NOTES
    Version:                1.0
    Author:                 https://github.com/sharket
    Created:                05/09/2023
    Last Updated:           N/A
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Exe,

    [string]$Args
)

$logName = "$($MyInvocation.MyCommand.Name)"
function Write-LogEntry {
    param (
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message,

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

$user = (Get-WmiObject -Class Win32_ComputerSystem).Username
$user = ($user -split "\\")[1]

$exeFullPath = "C:\Users\" + $user + "\AppData\Local\MicroSIP\Uninstall.exe"

Write-LogEntry -Message "#############################"
Write-LogEntry -Message "Architecture is $Env:PROCESSOR_ARCHITECTURE"
Write-LogEntry -Message "Starting: Run an executable in user space invoked from system context"
Write-LogEntry -Message "EXE path:    $($exeFullPath)"
Write-LogEntry -Message "Arguments:   $($Args)"

Try {
    Write-LogEntry -Message "Running command: Start-Process -FilePath $($exeFullPath) -ArgumentList $($Args) -Wait -PassThru"
    Start-Process -FilePath $exeFullPath -ArgumentList $Args -Wait -Passthru
    Write-LogEntry -Message "Executed successfully."
    Write-Host "OK"
}
Catch {
    Write-LogEntry -Level ERROR -Message "FAILED to execute"
    Write-LogEntry -Level ERROR -Message "$($_.Exception)"
    Write-Host "FAILED"
    Exit 1
}
