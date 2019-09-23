function New-BIGIQAuthenticationToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $RootUrl,

        [Parameter(Mandatory)]
        [PSCredential]
        $Credential,

        [Alias('LoginProviderName')]
        [string]
        $LoginReference = 'tmos',

        [switch]
        $PassThru
    )

    $requestParameters = @{
        username = $credential.Username
        password = $credential.GetNetworkCredential().Password
    }

    try {
        # BIG-IQ will use Login Reference with a link property for things like LDAP.
        # Those are specified via a fully qualified uri. If that is what's provided
        # form this additional parameter for the login appropriately.
        $test = New-Object System.Uri($loginReference)
        Write-Verbose 'Setting login reference'
        $requestParameters.loginReference = @{ link = $loginReference }
    } catch [System.Management.Automation.MethodInvocationException] {

        # If the given 'reference' is not a uri, simply default to the BIG-IP format.
        if($PSItem.Exception.Message -like '*Invalid URI: The format of the URI could not be determined.*') {
            Write-Verbose 'Setting login provider name'
            $requestParameters.loginProviderName = $loginReference
        }
    }

    $requestOptions = @{
        Uri = $rootUrl + '/mgmt/shared/authn/login'
        Body = ConvertTo-Json $requestParameters -Depth 2 -Compress
        Method = 'POST'
        UseBasicParsing = $true
    }

    Write-Verbose 'Getting BIG-IQ access token'
    $response = Invoke-RestMethod @requestOptions
    
    $BIGIQSession.rootUrl = $rootUrl
    $BIGIQSession.authResponse = $response
    $BIGIQSession.token = $response.token.token # Yes, token twice.

    if($PassThru.IsPresent) {
        $response | ConvertTo-Json | ConvertFrom-Json
    }
}