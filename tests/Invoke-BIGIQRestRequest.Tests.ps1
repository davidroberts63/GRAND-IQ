. $PSScriptRoot\Common.ps1

Describe 'Invoke-BIGIQRestRequest' {
    Mock -ModuleName GRAND-IQ Invoke-RestMethod -ParameterFilter { $Uri.AbsoluteUri.StartsWith('https://noop') } -MockWith { 
        return [PSCustomObject]@{
            token = [PSCustomObject]@{ token = 'atoken' }
        }
    }
    Mock -ModuleName GRAND-IQ Invoke-RestMethod { Write-Host $Uri.AbsolutePath; return @{ called = $true } }

    $credential = New-Object PSCredential('username', 'password' | ConvertTo-SecureString -AsPlainText -Force)
    New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential

    It 'makes the request using the session url' {
        Invoke-BIGIQRestRequest -path 'the/path' -method 'GET'

        Assert-MockCalled -ModuleName GRAND-IQ -CommandName Invoke-RestMethod -ParameterFilter { return $Uri.AbsoluteUri.StartsWith('https://localhost') }
    }
}