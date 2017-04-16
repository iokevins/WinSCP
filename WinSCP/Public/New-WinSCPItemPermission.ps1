function New-WinSCPItemPermission {
    
    [CmdletBinding(
        SupportsShouldProcess = $true,
        HelpUri = "http://dotps1.github.io/WinSCP/New-WinSCPItemPermission.html"
    )]
    [OutputType(
        [WinSCP.FilePermissions]
    )]

    param (
        [Parameter()]
        [Switch]
        $GroupExecute,

        [Parameter()]
        [Switch]
        $GroupRead,

        [Parameter()]
        [Switch]
        $GroupWrite,

        [Parameter()]
        [Int]
        $Numeric = $null,

        [Parameter()]
        [String]
        $Octal = $null,

        [Parameter()]
        [Switch]
        $OtherExecute,

        [Parameter()]
        [Switch]
        $OtherRead,

        [Parameter()]
        [Switch]
        $OtherWrite,

        [Parameter()]
        [Switch]
        $SetGid,

        [Parameter()]
        [Switch]
        $SetUid,

        [Parameter()]
        [Switch]
        $Sticky,

        [Parameter()]
        [String]
        $Text = $null,

        [Parameter()]
        [Switch]
        $UserExecute,

        [Parameter()]
        [Switch]
        $UserRead,

        [Parameter()]
        [Switch]
        $UserWrite
    )

    begin {
        $filePermmisions = New-Object -TypeName WinSCP.FilePermissions

        $shouldProcess = $PSCmdlet.ShouldProcess(
            $filePermmisions
        )
        if ($shouldProcess) {
            foreach ($key in $PSBoundParameters.Keys) {
                try {
                    $filePermmisions.$($key) = $PSBoundParameters.$($key)
                } catch {
                    Write-Error -Message $_.ToString()
                    continue
                }
            }
        }
    }

    end {
        return $filePermmisions
    }
}
