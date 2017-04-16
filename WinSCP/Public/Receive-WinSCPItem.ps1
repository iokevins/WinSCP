function Receive-WinSCPItem {
    
    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/Receive-WinSCPItem.html"
    )]
    [OutputType(
        [WinSCP.TransferOperationResult]
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
        $Path,

        [Parameter()]
        [String]
        $Destination = $pwd,

        [Parameter()]
        [Switch]
        $Remove,

        [Parameter()]
        [WinSCP.TransferOptions]
        $TransferOptions = (New-Object -TypeName WinSCP.TransferOptions)
    )

    begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )

        $destinationEndsWithSlash = $Destination.EndsWith(
            [System.IO.Path]::DirectorySeparatorChar
        )
        if ((Get-Item -Path $Destination -ErrorAction SilentlyContinue).PSIsContainer -and -not $destinationEndsWithSlash) {
            $Destination += "\"
        }
    }

    process {
        foreach ($pathValue in (Format-WinSCPPathString -Path $($Path))) {
            try {
                $result = $WinSCPSession.GetFiles(
                    $pathValue, $Destination, $Remove.IsPresent, $TransferOptions
                )

                if ($result.IsSuccess) {
                    Write-Output -InputObject $result
                } else {
                    $result.Failures[0] | 
                        Write-Error
                }
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
