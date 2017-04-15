function Invoke-WinSCPCommand {

    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/Invoke-WinSCPCommand.html"
    )]
    [OutputType(
        [WinSCP.CommandExecutionResult]
    )]

    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateScript({ 
            if ($_.Opened) { 
                return $true 
            } else { 
                throw "The WinSCP Session is not in an Open state."
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

    begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )
    }

    process {
        foreach ($commandValue in $Command) {
            try {
                $output = $WinSCPSession.ExecuteCommand(
                    $commandValue
                )

                Write-Output -InputObject $output
            } catch {
                Write-Error -Message $_.ToString()
                continue
            }
        }
    }

    end {
        if (-not ($sessionValueFromPipeLine)) {
            Remove-WinSCPSession -WinSCPSession $WinSCPSession
        }
    }
}
