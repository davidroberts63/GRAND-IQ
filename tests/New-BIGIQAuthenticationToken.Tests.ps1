. $PSScriptRoot\Common.ps1

Describe 'New-BIGIQAuthenticationToken' {
    Mock -ModuleName GRAND-IQ Invoke-RestMethod -MockWith { 
        return [PSCustomObject]@{
            token = [PSCustomObject]@{ token = 'atoken' }
        }
    }
    $credential = New-Object PSCredential('username', ('password' | ConvertTo-SecureString -AsPlainText -Force))

    It 'sends the request to the login url' {
        New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential
        Assert-MockCalled Invoke-RestMethod -ParameterFilter { $Uri.AbsolutePath -eq '/mgmt/shared/authn/login' } -ModuleName GRAND-IQ
    }

    It 'specifies the correct login reference structure when a uri' {
        New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential -loginReference 'http://www.example.com/'
        Assert-MockCalled Invoke-RestMethod -ParameterFilter { 
            $payload = $Body | ConvertFrom-Json

            return $payload.loginReference -and $payload.loginReference.link -and ($payload.loginReference.link -eq 'http://www.example.com/')
        } -ModuleName GRAND-IQ
    }

    It 'specifies the correct login provider name when NOT a uri' {
        New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential -loginReference 'some-reference-name'
        Assert-MockCalled Invoke-RestMethod -ParameterFilter { 
            $payload = $Body | ConvertFrom-Json

            return $payload.loginProviderName -and ($payload.loginProviderName -eq 'some-reference-name')
        } -ModuleName GRAND-IQ
    }

    It 'passes the session data through' {
        $output = New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential -PassThru

        $output | Should -Not -BeNullOrEmpty
    }

}