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

    It 'specifies the correct login reference structure' {
        New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential -loginReference 'some-login-reference-url'
        Assert-MockCalled Invoke-RestMethod -ParameterFilter { 
            $payload = $Body | ConvertFrom-Json
            
            return $payload.loginReference -and $payload.loginReference.link -and ($payload.loginReference.link -eq 'some-login-reference-url')
        } -ModuleName GRAND-IQ
    }

}