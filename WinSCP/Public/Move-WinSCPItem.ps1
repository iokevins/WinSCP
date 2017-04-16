function Move-WinSCPItem {

    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/Move-WinSCPItem.html"
    )]
    [OutputType(
        [Void]
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
        $Destination = "/",

        [Parameter()]
        [Switch]
        $Force,

        [Parameter()]
        [Switch]
        $PassThru
    )

    begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )
    }

    process {
        if (-not (Test-WinSCPPath -WinSCPSession $WinSCPSession -Path ($Destination = Format-WinSCPPathString -Path $($Destination)))) {
            if ($Force.IsPresent) {
                New-WinSCPItem -WinSCPSession $WinSCPSession -Path $Destination -ItemType Directory
            } else {
                Write-Error -Message "Could not find a part of the path."
                return
            }
        }

        foreach ($pathValue in (Format-WinSCPPathString -Path $($Path))) {
            try {
                $destinationEndsWithPathValue = $Destination.EndsWith(
                    $pathValue
                )
                $destinationEndsWithSlash = $Destination.EndsWith(
                    "/"
                )
                if (-not $destinationEndsWithPathValue -and -not $destinationEndsWithSlash) {
                    $Destination += "/"
                }

                $WinSCPSession.MoveFile(
                    $pathValue.TrimEnd(
                        "/"
                    ), $Destination
                )

                if ($PassThru.IsPresent) {
                    Get-WinSCPItem -WinSCPSession $WinSCPSession -Path (Join-Path -Path $Destination -ChildPath (Split-Path -Path $item -Leaf))
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
