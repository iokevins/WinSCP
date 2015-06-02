﻿<#
.SYNOPSIS
    Moves an item from one location to another from an active WinSCP Session.
.DESCRIPTION
    Once connected to an active WinSCP Session, one or many files can be moved to another location within the same WinSCP Session.
.INPUTS
    WinSCP.Session.
.OUTPUTS
    None.
.PARAMETER WinSCPSession
    A valid open WinSCP.Session, returned from Open-WinSCPSession.
.PARAMETER Path
    Full path to remote item to be moved.
.PARAMETER Destination
    Full path to new location to move the item to.
.EXAMPLE
    PS C:\> Open-WinSCPSession -SessionOptions (New-WinSCPSessionOptions -Hostname 'myftphost.org' -Username 'ftpuser' -Password 'FtpUserPword' -Protocol Ftp) | Move-WinSCPItem -Path './rDir/rFile.txt' -Destination './rDir/rSubDir/'
.EXAMPLE
    PS C:\> $session = New-WinSCPSessionOptions -Hostname 'myftphost.org' -Username 'ftpuser' -Password 'FtpUserPword' -SshHostKeyFingerprint 'ssh-rsa 1024 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx' | Open-WinSCPSession
    PS C:\> Move-WinSCPItem -WinSCPSession $session -Path './rDir/rFile.txt' -Destination './rDir/rSubDir/'
.NOTES
    If the WinSCPSession is piped into this command, the connection will be disposed upon completion of the command.
.LINK
    http://dotps1.github.io/WinSCP
.LINK 
    http://winscp.net/eng/docs/library_session_movefile
#>
Function Move-WinSCPItem
{
    [CmdletBinding()]
    [OutputType([Void])]
    
    Param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeLine = $true)]
        [ValidateScript({ if ($_.Open)
            { 
                return $true 
            }
            else
            { 
                throw 'The WinSCP Session is not in an Open state.' 
            } })]
        [WinSCP.Session]
        $WinSCPSession,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ -not ([String]::IsNullOrWhiteSpace($_)) })]
        [String[]]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ -not ([String]::IsNullOrWhiteSpace($_)) })]
        [String]
        $Destination
    )

    Begin
    {
        $sessionValueFromPipeLine = $PSBoundParameters.ContainsKey('WinSCPSession')
    }

    Process
    {
        foreach ($item in $Path.Replace('\','/').TrimEnd('/'))
        {
            try
            {
                if (-not ($Destination.EndsWith('/')))
                {
                    $Destination += '/'
                }

                if (-not (Test-WinSCPPath -WinSCPSession $WinSCPSession -Path $Destination))
                {
                    New-WinSCPDirectory -WinSCPSession $WinSCPSession -Path $Destination | Out-Null
                }

                Write-Verbose -Message "Performing the operation `"Move WinSCPItem`" on target `"Item: $item Destination: $($Destination.Replace('\','/'))`"."
                $WinSCPSession.MoveFile($item, $Destination.Replace('\','/'))
            }
            catch [System.Exception]
            {
                Write-Error -ErrorRecord $_
                
                continue
            }
        }
    }

    End
    {
        if (-not ($sessionValueFromPipeLine))
        {
            Close-WinSCPSession -WinSCPSession $WinSCPSession
        }
    }
}