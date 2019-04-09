function New-BIGIQAuthenticationToken {
    [CmdletBinding()]
    param(
        $rootUrl,
        [PSCredential]
        $credential,
        $loginReference,
        [switch]
        $PassThru
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

    Write-Verbose 'Getting BIG-IQ access token'
    $response = Invoke-RestMethod @requestOptions
    
    $BIGIQSession = New-Object PSCustomObject -Property @{
        rootUrl = $rootUrl
        authResponse = $response
        token = $response.token.token # Yes, token twice.
    }

    if($PassThru.IsPresent) {
        $response | ConvertTo-Json | ConvertFrom-Json
    }
}