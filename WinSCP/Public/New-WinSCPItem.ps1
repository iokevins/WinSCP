function New-WinSCPItem {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        HelpUri = "http://dotps1.github.io/WinSCP/New-WinSCPItem.html"
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

        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [String]
        $Name = $null,

        [Parameter()]
        [String]
        $ItemType = "File",

        [Parameter()]
        [String]
        $Value = $null,

        [Parameter()]
        [Switch]
        $Force,

        [Parameter()]
        [WinSCP.TransferOptions]
        $TransferOptions = (New-Object -TypeName WinSCP.TransferOptions)
    )

    begin {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey(
            "WinSCPSession"
        )
    }

    process {
        foreach ($pathValue in (Format-WinSCPPathString -Path $($Path))) {
            $parameterNameExists = $PSBoundParameters.ContainsKey(
                "Name"
            )
            if ($parameterNameExists) {
                $pathValue = Format-WinSCPPathString -Path $(Join-Path -Path $pathValue -ChildPath $Name)
            }

            if (-not (Test-WinSCPPath -WinSCPSession $WinSCPSession -Path (Split-Path -Path $pathValue -Parent))) {
                Write-Error -Message "Could not find a part of the path '$pathValue'."
                continue
            }

            if ((Test-WinSCPPath -WinSCPSession $WinSCPSession -Path $pathValue) -and -not $Force.IsPresent) {
                Write-Error -Message "An item with the spcified name '$pathValue' already exists."
                continue
            } 

            try {
                $newItemParams = @{
                    Path = $env:TEMP
                    Name = (Split-Path -Path $pathValue -Leaf)
                    ItemType = $ItemType
                    Value = $Value
                    Force = $true
                }

                $shouldProcess = $PSCmdlet.ShouldProcess(
                    $pathValue
                )
                if ($shouldProcess) {
                    $result = $WinSCPSession.PutFiles(
                        (New-Item @newItemParams).FullName, $pathValue, $true, $TransferOptions
                    )

                    if ($result.IsSuccess) {
                        Get-WinSCPItem -WinSCPSession $WinSCPSession -Path $pathValue
                    } else {
                        Write-Error $result.Check()
                        continue
                    }
                }
            } catch {
                Write-Error -Message $_.ToString()
            }
        }
    }

    end {
        if (-not ($sessionValueFromPipeLine)) {
            Remove-WinSCPSession -WinSCPSession $WinSCPSession
        }
    }
}
