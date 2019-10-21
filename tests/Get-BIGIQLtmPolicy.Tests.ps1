. $PSScriptRoot\Common.ps1

Describe 'Get-BIGIQLtmPolicy' {
    Mock -ModuleName GRAND-IQ Invoke-RestMethod -ParameterFilter { $Uri.AbsolutePath -eq '/mgmt/shared/authn/login' } -MockWith { 
        return [PSCustomObject]@{
            token = [PSCustomObject]@{ token = 'atoken' }
        }
    }
    Mock -ModuleName GRAND-IQ Invoke-RestMethod { return [PSCustomObject]@{ called = $true; items = @('one') } }

    $credential = New-Object PSCredential('username', 'password' | ConvertTo-SecureString -AsPlainText -Force)
    New-BIGIQAuthenticationToken -rootUrl 'https://noop' -credential $credential

    It 'returns a result including the total count' {
        $result = Get-BIGIQLtmPolicy -IncludeTotalCount

        $result.TotalCount | Should -BeGreaterThan 0
    }
}