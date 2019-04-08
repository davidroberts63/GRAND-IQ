function New-BIGIQAuthenticationToken {
    [CmdletBinding()]
    param(
        $rootUrl,
        [PSCredential]
        $credential,
        $loginReference,
        [switch]
        $setSession
    )

    $requestParameters = @{
        username = $credential.Username
        password = $credential.GetNetworkCredential().Password
        loginReference = @{ link = $loginReference }
    }

    $requestOptions = @{
        Uri = $rootUrl + '/mgmt/shared/authn/login'
        Body = ConvertTo-Json $requestParameters -Depth 2 -Compress
        Method = 'POST'
        UseBasicParsing = $true
    }

    $response = Invoke-RestMethod @requestOptions
    
    $response | Write-Output
    if($setSession.IsPresent) {
        Write-Verbose 'Setting BIG-IQ session'
        $Script:Session = New-Object PSCustomObject -Property @{
            rootUrl = $rootUrl
            authResponse = $response
            token = $response.token.token # Yes, token twice.
        }
    }
}