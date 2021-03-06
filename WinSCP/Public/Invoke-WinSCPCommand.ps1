﻿Function Invoke-WinSCPCommand {
    [CmdletBinding(
        HelpUri = 'https://github.com/dotps1/WinSCP/wiki/Invoke-WinSCPCommand'
    )]
    [OutputType(
        [WinSCP.CommandExecutionResult]
    )]

    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateScript({ 
            if ($_.Opened) { 
                return $true 
            } else { 
                throw 'The WinSCP Session is not in an Open state.'
            }
        })]
        [WinSCP.Session]
        $WinSCPSession,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]
        $Command
    )

    Begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey('WinSCPSession')
    }

    Process {
        foreach ($commandment in $Command) {
            try {
                $WinSCPSession.ExecuteCommand($commandment)
            } catch {
                Write-Error -Message $_.ToString()
            }
        }
    }

    End {
        if (-not ($sessionValueFromPipeLine)) {
            Remove-WinSCPSession -WinSCPSession $WinSCPSession
        }
    }
}