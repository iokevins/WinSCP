function New-WinSCPSession {

    [CmdletBinding(
        SupportsShouldProcess = $true,
        HelpUri = "http://dotps1.github.io/WinSCP/New-WinSCPSession.html"
    )]
    [OutputType(
        [WinSCP.Session]
    )]
    
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [WinSCP.FtpMode]
        $FtpMode = (New-Object -TypeName WinSCP.FtpMode),

        [Parameter()]
        [WinSCP.FtpSecure]
        $FtpSecure = (New-Object -TypeName WinSCP.FtpSecure),
        
        [Parameter()]
        [Switch]
        $GiveUpSecurityAndAcceptAnySshHostKey,

        [Parameter()]
        [Switch]
        $GiveUpSecureityAndAcceptAnyTlsHostCertificate,

        [Parameter(
            Mandatory = $true
        )]
        [String]
        $HostName = $null,

        [Parameter()]
        [Int]
        $PortNumber = 0,

        [Parameter()]
        [WinSCP.Protocol]
        $Protocol = (New-Object -TypeName WinSCP.Protocol),

        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [String[]]
        $SshHostKeyFingerprint = $null,

        [Parameter()]
        [ValidateScript({ 
            if (Test-Path -Path $_) { 
                return $true 
            } else { 
                throw "Cannot find path: '$_' because it does not exist."
            } 
        })]
        [String]
        $SshPrivateKeyPath = $null,

        [Parameter(
			ValueFromPipelineByPropertyName = $true
		)]
        [SecureString]
        $SshPrivateKeySecurePassphrase = $null,

        [Parameter(
			ValueFromPipelineByPropertyName = $true
		)]
        [String]
        $TlsHostCertificateFingerprint = $null,

        [Parameter()]
        [TimeSpan]
        $Timeout = (New-TimeSpan -Seconds 15),

        [Parameter()]
        [Switch]
        $WebdavSecure,

        [Parameter()]
        [String]
        $WebdavRoot = $null,
        
        [Parameter()]
        [HashTable]
        $RawSetting = $null,

        [Parameter()]
        [ValidateScript({
            if (Test-Path -Path (Split-Path -Path $_)) {
                return $true
            } else {
                throw "Cannot find path: '$_' because it does not exist."
            } 
        })]
        [String]
        $DebugLogPath = $null,

        [Parameter()]
        [ValidateScript({
            if (Test-Path -Path (Split-Path -Path $_)) {
                return $true
            } else {
                throw "Cannot find path: '$_' because it does not exist."
            } 
        })]
        [String]
        $SessionLogPath = $null,

        [Parameter()]
        [TimeSpan]
        $ReconnectTime = (New-TimeSpan -Seconds 120),

        [Parameter()]
        [ScriptBlock]
        $FileTransferProgress = $null
    )

    # Create WinSCP.Session and WinSCP.SessionOptions Objects, parameter values will be assigned to matching object properties.
    $sessionOptions = New-Object -TypeName WinSCP.SessionOptions
    $session = New-Object -TypeName WinSCP.Session -Property @{
        ExecutablePath = "$PSScriptRoot\..\bin\winscp.exe"
    }

    # Convert PSCredential Object to match names of the WinSCP.SessionOptions Object.
    $PSBoundParameters.Add(
        "UserName", $Credential.UserName
    )
    $PSBoundParameters.Add(
        "SecurePassword", $Credential.Password
    )

    # Resolve Full Path, WinSCP.exe does not like dot sourced path for the Certificate.
    $parameterSshPrivateKeyPathExist = $PSBoundParameters.ContainsKey(
        "SshPrivateKeyPath"
    )
    if ($parameterSshPrivateKeyPathExist) {
        $PSBoundParameters.SshPrivateKeyPath = $SshPrivateKeyPath
    }

    # Convert SshPrivateKeySecurePasspahrase to plain text and set it to the corresponding SessionOptions property.
    if ($SshPrivateKeySecurePassphrase -ne $null) {
		try {
			$sessionOptions.SshPrivateKeyPassphrase = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
                    $SshPrivateKeySecurePassphrase
                )
            )
		} catch {
			Write-Error -Message $_.ToString()
			return $null
		}
    }

    try {
        # Enumerate each parameter.
        foreach ($key in $PSBoundParameters.Keys) {
            # If the property is a member of the WinSCP.SessionOptions object, set the matching value.
            $sessionOptionsProperties = ($sessionOptions | 
                Get-Member -MemberType Properties).Name 
            if ($sessionOptionsProperties -contains $key) {
                $sessionOptions.$key = $PSBoundParameters.$key
            }

            # If the property is a member of the WinSCP.Session object, set the matching value.
            $sessionProperties = ($session | 
                Get-Member -MemberType Properties).Name
            elseif ($sessionProperties -contains $key) {
                $session.$key = $PSBoundParameters.$key
            }
        }

        # Enumerate raw settings and add the options to the WinSCP.SessionOptions object.
        $parameterRawSettingsExist = $PSBoundParameters.ContainsKey(
            "RawSettings"
        )
        if ($parameterRawSettingsExist) {
            foreach ($key in $RawSetting.Keys) {
                $sessionOptions.AddRawSettings(
                    $key, $RawSetting[$key]
                )
            }
        }

		# Add FileTransferProgress ScriptBlock if present.
        $parameterFieTransferProgressExist = $PSBoundParameters.ContainsKey(
            "FileTransferProgress"
        )
        if ($parameterFieTransferProgressExist) {
            $session.Add_FileTransferProgress(
                $FileTransferProgress
            )
        }
    } catch {
        Write-Error -Message $_.ToString()
		return $null
    }

    $shouldProcess = $PSCmdlet.ShouldProcess(
        $session
    )
    if ($shouldProcess) {
	    try {
	        # Open the WinSCP.Session object using the WinSCP.SessionOptions object.
            $session.Open(
                $sessionOptions
            )

            # Set the default -WinSCPSession Parameter Value for other cmdlets.
            Get-Command -Module WinSCP -ParameterName WinSCPSession | ForEach-Object {
                $Global:PSDefaultParameterValues.Remove(
                    "$($_.Name):WinSCPSession"
                )
                $Global:PSDefaultParameterValues.Add(
                    "$($_.Name):WinSCPSession", $session
                )
            }

            # Return the WinSCP.Session object.
            return $session
	    } catch {
	        Write-Error -Message $_.ToString()
            $session.Dispose()
		    return $null
	    }
    }
}
