#requires -Modules Pester, PSScriptAnalyzer

Get-Process | Where-Object { $_.Name -eq 'WinSCP' } | Stop-Process -Force

Describe 'New-WinSCPSession' {
    $credential = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'filezilla', (ConvertTo-SecureString -AsPlainText 'filezilla' -Force))

    Context "New-WinSCPSession -Credential `$credential -HostName $env:COMPUTERNAME -Protocol Ftp" {
        $session = New-WinSCPSession -Credential $credential -HostName $env:COMPUTERNAME -Protocol Ftp

        It 'Session should be open.' {
            $session.Opened | Should Be $true
        }

        It "Hostname should be $env:COMPUTERNAME." {
            $session
        }

        It 'Session should be closed and the object should be disposed.' {
            Remove-WinSCPSession -WinSCPSession $session
            $session | Should Not Exist
        }
    }

    Context "New-WinSCPSession -Credential `$credential -HostName $env:COMPUTERNAME -Protocol Ftp -SessionLogPath $env:TEMP\Session.log -DebugLogPath $env:TEMP\Debug.log" {
        $session = New-WinSCPSession -Credential $credential -HostName $env:COMPUTERNAME -Protocol Ftp -SessionLogPath "$env:TEMP\Session.log" -DebugLogPath "$env:TEMP\Debug.log"

        It 'Session should be open.' {
            $session.Opened | Should Be $true
        }

        It "$env:TEMP\Session.log should exist." {
            Test-Path -Path "$env:TEMP\Session.log" | Should Be $true
        }

        It "$env:TEMP\Debug.log should exist." {
            Test-Path -Path "$env:TEMP\Debug.log" | Should Be $true
        }

        It 'Session should be closed and the object should be disposed.' {
            Remove-WinSCPSession -WinSCPSession $session
            $session | Should Not Exist
        }

        Remove-Item -Path @("$env:TEMP\Session.log", "$env:TEMP\Debug.log") -Force -Confirm:$false
    }

    Context "Invoke-ScriptAnalyzer -Path $(Resolve-Path -Path (Get-Location))\Functions\New-WinSCPSession.ps1." {
        $results = Invoke-ScriptAnalyzer -Path .\WinSCP\Public\New-WinSCPSession.ps1

        it 'Invoke-ScriptAnalyzer results of New-WinSCPSession count should be 0.' {
            $results.Count | Should Be 0
        }
    }
}
