function New-BIGIQAuthenticationToken {
    <#
    .SYNOPSIS
    Aquires an authorization token from a BIG-IQ or BIG-IP device; saving it into a session object for use in future calls.

    .DESCRIPTION
    Given a fully qualified RootUrl and appropriate user Credential, this posts to the authn endpoint on a BIG-IP or BIG-IQ device. The resulting authentication token is stored in a session object that Invoke-BIGIQRestRequest will use automatically. The LoginReference (alias LoginProviderName) will adjust the login payload appropriately.

    .PARAMETER RootUrl
    The fully qualified URL to the root of your BIG-IP or BIG-IQ device.

    .PARAMETER Credential
    The credentials for authenticating with the BIG-IP or BIG-IQ device.

    .PARAMETER LoginReference
    The URL to the login provider (typically for BIG-IQ) or the simple name of the provider (for BIG-IP). If a URL the login will add this login reference within a 'link' property in the 'loginReference' payload property. Defaults to 'tmos'.

    .PARAMETER PassThru
    Will return the authorization token that you can use yourself for other purposes. Or to switch between different devices.

    .EXAMPLE
    New-BIGIQAuthentication -RootUrl 'https://testbigiq.test.com' -Credential (Get-Credential)
    #>
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

    # Big-IP does not handle empty segments well especially in authentication.
    $rootUrl = $rootUrl -replace '/$',''

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
    
    Set-BIGIQSession -RootUrl $RootUrl -Token $response.token.token # Yes, token twice.

    if($PassThru.IsPresent) {
        $response | ConvertTo-Json | ConvertFrom-Json
    }
}

function Set-BIGIQSession {
    <#
    .SYNOPSIS
    Sets the session object for use in future calls.

    .DESCRIPTION
    Sets the token and root url that future REST calls will use for authentication and requests.

    .PARAMETER RootUrl
    The fully qualified URL to the root of your BIG-IP or BIG-IQ device.

    
    .PARAMETER Token
    The authentication token from the BIG-IP/IQ. You can also use the $response.token.token value from an earlier call to New-BIGIQAuthenticationToken -PassThru

    .EXAMPLE
    Set-BIGIQSession -RootUrl 'https://testbigiq.test.com' -Token $response.token.token
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $RootUrl,

        [string]
        $Token
    )

    $BIGIQSession.rootUri = (New-Object System.UriBuilder($RootUrl)).Uri
    $BIGIQSession.token = $Token

}