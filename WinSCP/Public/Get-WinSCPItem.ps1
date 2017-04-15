function Get-WinSCPItem {
    
    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/Get-WinSCPItem.html"
    )]
    [OutputType(
        [WinSCP.RemoteFileInfo]
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
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]
        $Path = "/",

        [Parameter()]
        [String]
        $Filter = "*"
    )

    begin {
        $sessionValueFromPipeline = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )
    }

    process {
        foreach ($pathValue in (Format-WinSCPPathString -Path $($Path))) {
            if (-not (Test-WinSCPPath -WinSCPSession $WinSCPSession -Path $pathValue)) {
                Write-Error -Message "Cannot find path: '$pathValue' because it does not exist."
                continue
            }

            $parameterFilterExists = $PSBoundParameters.ContainsKey(
                "Filter"
            )
            if ($parameterFilterExists) {
                Get-WinSCPChildItem -WinSCPSession $WinSCPSession -Path $pathValue -Filter $Filter
            } else {
                try {
                    $WinSCPSession.GetFileInfo(
                        $pathValue
                    )
                } catch {
                    Write-Error -Message $_.ToString()
                    continue
                }
            }
        }
    }

    end {
        if (-not ($sessionValueFromPipeline)) {
            Remove-WinSCPSession -WinSCPSession $WinSCPSession
        }
    }
}
