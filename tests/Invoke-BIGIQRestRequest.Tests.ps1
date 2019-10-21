. $PSScriptRoot\Common.ps1

Describe 'Invoke-BIGIQRestRequest' {
    Mock -ModuleName GRAND-IQ Invoke-RestMethod -ParameterFilter { $Uri.AbsolutePath -eq '/mgmt/shared/authn/login' } -MockWith { 
        return [PSCustomObject]@{
            token = [PSCustomObject]@{ token = 'atoken' }
        }
    }
    Mock -ModuleName GRAND-IQ Invoke-RestMethod { return [PSCustomObject]@{ called = $true; items = @('one') } }

    $credential = New-Object PSCredential('username', 'password' | ConvertTo-SecureString -AsPlainText -Force)
    New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential

    It 'makes the request using the session url' {
        Invoke-BIGIQRestRequest -path '/the/path' -method 'GET'

        Assert-MockCalled -CommandName Invoke-RestMethod -ParameterFilter { return $Uri.AbsoluteUri.StartsWith('https://noop') -and ($Uri.AbsolutePath -eq '/the/path') } -ModuleName GRAND-IQ
    }

    It 'makes the request using the top paging parameter' {
        Invoke-BIGIQRestRequest -Path '/the/path' -Method 'GET' -First 2 -Skip 3

        $inThisManner = @{
            CommandName = 'Invoke-RestMethod'
            ParameterFilter = {
                return $Uri.Query.Contains('%24top=2')
            }
            ModuleName = 'GRAND-IQ'
        }
        Assert-MockCalled @inThisManner
    }

    It 'makes the request using the skip paging parameter' {
        Invoke-BIGIQRestRequest -Path '/the/path' -Method 'GET' -First 2 -Skip 3

        $inThisManner = @{
            CommandName = 'Invoke-RestMethod'
            ParameterFilter = {
                return $Uri.Query.Contains('%24skip=3')
            }
            ModuleName = 'GRAND-IQ'
        }
        Assert-MockCalled @inThisManner
    }
}