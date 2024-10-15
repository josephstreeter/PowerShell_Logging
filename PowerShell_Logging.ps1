[cmdletbinding()]
param
(
    [Parameter(Mandatory = $false)][ValidateSet('Info', 'Warning', 'Error', 'Verbose', 'Debug')][string]$LogLevel = 'Info'
)

Function Write-Log 
{
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][ValidateSet('Info', 'Warning', 'Error', 'Verbose', 'Debug')][string]$Severity = 'Info',
        [Parameter(Mandatory = $false)][ValidateSet('Info', 'Warning', 'Error', 'Verbose', 'Debug')][string]$LogLevel = 'Info',
        [Parameter(Mandatory = $false)][switch]$LogToFile,
        [Parameter(Mandatory = $false)][string]$LogFileName
    )

    function Write-LogToFile
    {
        param
        (
            [Parameter(Mandatory = $true)][string]$DateTime,
            [Parameter(Mandatory = $true)][string]$Severity,
            [Parameter(Mandatory = $true)][string]$Message,
            [Parameter(Mandatory = $false)][string]$LogFileName
        )
        
        If (!( $LogFileName))
        {
            # LogFile parameter not specified (null), so determine one
            $LogFolder = $PSScriptRoot
            $LogName = Split-Path -Path $MyInvocation.ScriptName -LeafBase
            $LogFileName = Join-Path -Path $LogFolder -ChildPath ('{0}-{1}.log' -f [string](Get-Date -format "yyyyMMdd"), $LogName)
        }
        
        [pscustomobject]@{
            Time     = $DateTime
            Severity = $Severity
            Message  = $Message
        } | Export-Csv -Path $LogFileName -Append -NoTypeInformation
    }


    $DateTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    
    Write-Output "LogLevel $LogLevel"

    Switch ($Severity) 
    {
        'Error'
        {
            if ("Error" -notcontains $LogLevel)
            {
                $FormattedMessage = '[ERROR] {0} {1}' -f $Message, $DateTime
                Write-Error $FormattedMessage       
            }

            If ( $LogToFile)
            {
                Write-LogToFile -DateTime $DateTime -Message $FormattedMessage -Severity $Severity -LogFileName $LogFileName
            }
        }
        'Warning'
        {
            if ("Error", "Warning" -notcontains $LogLevel)
            {
                $FormattedMessage = '[WARNING] {0} {1}' -f $Message, $DateTime
                Write-Warning -Message $FormattedMessage -WarningAction Continue
            }

            If ($LogToFile)
            {
                Write-LogToFile -DateTime $DateTime -Message $FormattedMessage -Severity $Severity -LogFileName $LogFileName
            }
        }
        'Info'
        {
            if ("Error", "Warning", "Info" -notcontains $LogLevel)
            {
                $FormattedMessage = '[Info]{0} {1}' -f $Message, $DateTime
                Write-Information $FormattedMessage -InformationAction Continue
            }
        }
        'Verbose'
        {
            if ("Error", "Warning", "Info","Verbose" -notcontains $LogLevel)
            {
                $FormattedMessage = '{0} {1}' -f $Message, $DateTime
                Write-Verbose $FormattedMessage -Verbose
            }

            If ( $LogToFile)
            {
                Write-LogToFile -DateTime $DateTime -Message $FormattedMessage -Severity $Severity -LogFileName $LogFileName
            }
        }
        'Debug'
        {
            if ("Error", "Warning", "Info", "Verbose", "Debug" -notcontains $LogLevel)
            {
                $FormattedMessage = '{0} {1}' -f $Message, $DateTime
                Write-Debug $FormattedMessage -Debug
            }

            If ( $LogToFile)
            {
                Write-LogToFile -DateTime $DateTime -Message $FormattedMessage -Severity $Severity -LogFileName $LogFileName
            }
        }
        Default
        {
            #$FormattedMessage = '{0}' -f $Message
            #Write-Host $FormattedMessage
        }
    }
}

Write-Log -Severity Info -Message "Test info" 

write-log -Severity info -Message "This Info should not show" 

Write-Log -Severity Warning -Message "Test warning" 
