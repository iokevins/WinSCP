function New-WinSCPTransferResumeSupport {

    [CmdletBinding(
        HelpUri = "http://dotps1.github.io/WinSCP/New-WinSCPTransferResumeSupport.html"
    )]
    [OutputType(
        [WinSCP.TransferResumeSupport]
    )]

    param (
        [Parameter()]
        [WinSCP.TransferResumeSupportState]
        $State = (New-Object -TypeName WinSCP.TransferResumeSupportState),

        [Parameter()]
        [Int]
        $Threshold
    )
       
    $transferResumeSupport = New-Object -TypeName WinSCP.TransferResumeSupport

    foreach ($key in $PSBoundParameters.Keys) {
        try {
            $transferResumeSupport.$($key) = $PSBoundParameters.$($key)
        } catch {
            Write-Error -Message $_.ToString()
            return $null
        }
    }

    Write-Output -InputObject $transferResumeSupport
}
