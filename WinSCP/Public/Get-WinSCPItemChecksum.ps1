function Get-WinSCPItemChecksum {

    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/Get-WinSCPItemChecksum.html"
    )]
    [OutputType(
        [Array]
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
            Mandatory = $true
        )]
        [String]
        $Algorithm,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]
        $Path
    )

    begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )
    }

    process {
        foreach ($pathValue in (Format-WinSCPPathString -Path $($Path))) {
            if (-not (Test-WinSCPPath -WinSCPSession $WinSCPSession -Path $pathValue)) {
                Write-Error -Message "Cannot find path: '$pathValue' because it does not exist."
                continue
            }

            try {
                $output = $WinSCPSession.CalculateFileChecksum(
                    $Algorithm, $pathValue
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
