﻿function ConvertTo-WinSCPEscapedString {
    
    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/ConvertTo-WinSCPEscapedString.html"
    )]
    [OutputType(
        [String]
    )]

    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]
        $FileMask
    )

    begin {
        $sessionObject = New-Object -TypeName WinSCP.Session
    }

    process {
        foreach ($fileMaskValue in $FileMask) {
            try {
                $output = $sessionObject.EscapeFileMask(
                    $fileMaskValue
                )

                Write-Output -InputObject $output
            } catch {
                Write-Error -Message $_.ToString()
                continue
            }
        }
    }
    
    end {
        $sessionObject.Dispose()
    }
}
