function Invoke-BIGIQRestRequest {
    <#
    .SYNOPSIS
    Aquires an authorization token from a BIG-IQ or BIG-IP device; saving it into a session object for use in future calls.

    .DESCRIPTION
    Given a fully qualified RootUrl and appropriate user Credential, this posts to the authn endpoint on a BIG-IP or BIG-IQ device. The resulting authentication token is stored in a session object that Invoke-BIGIQRestRequest will use automatically. The LoginReference (alias LoginProviderName) will adjust the login payload appropriately.

    .PARAMETER Link
    A fully qualifified URI to call. This is best used with selfLink properties in the responses from the BIG-IQ or BIG-IP. When used, the host in the Link value will be replaced with the RootUrl from the session.

    .PARAMETER Path
    The path of the URL to call. This is combined with the RootUrl given in the New-BIGIQAuthenticationToken or the RootUrl used in Set-BIGIQSession

    .PARAMETER Method
    The REST Method to use in the HTTP call.

    .PARAMETER RequestParameters
    An object containing the data to pass as the content (body) of the request as JSON. If a string it will pass that data as the content unchanged.

    .PARAMETER ExpandSubCollections
    If present will expand sub collections in the REST API call.

    .PARAMETER SessionToken
    The authentication token retrieved from a prior call to New-BIGIQAuthenticationToken or REST call.

    .EXAMPLE
    New-BIGIQAuthentication -RootUrl 'https://testbigiq.test.com' -Credential (Get-Credential)
    #>
    [CmdletBinding(SupportsShouldProcess, SupportsPaging)]
    param(
        $Link,

        $Path,

        $Method = 'GET',

        [Alias('Body')]
        $RequestParameters,

        [String]$Filter,
        [String]$Select,

        [switch]
        $ExpandSubCollections,

        $SessionToken # Might want to switch this to a WebSession object.
    )

    process {
        if(-not $SessionToken) {
            $SessionToken = $BIGIQSession.token
        }

        if($Link) {
            $uri = New-Object System.Uri($Link)
            $Path = $uri.PathAndQuery
        }
        $uriParameters = @{
            Filter = $Filter
            Select = $Select
            First = $PSCmdlet.PagingParameters.First
            Skip = $PSCmdlet.PagingParameters.Skip
            ExpandSubCollections = $ExpandSubCollections.IsPresent
        }
        $uriBuilder = CreateUriBuilder -rootUri $BIGIQSession.rootUri -path $Path @uriParameters

        # Build out the parameters for the Invoke-RestMethod
        # TODO: Add ability to add other Invoke-RestMethod parameters. Though this would be leaky if the way of calling is ever changed.
        $options = @{
            Uri = $uriBuilder.Uri
            Method = $method
            Headers = @{ 'X-F5-Auth-Token' = $SessionToken; 'Content-Type' = 'application/json' } # TODO: Add ability to add custom headers
        }
        if($RequestParameters -is [String]) {
            $options.Body = $RequestParameters
        } else {
            $options.Body = ConvertTo-Json $requestParameters -Compress
        }

        if($options.Body) {
            Write-Verbose 'Request body:'
            $options.Body | Write-Verbose
        }
        if($PSCmdlet.ShouldProcess($Path)) {
            Invoke-RestMethod @options | Write-Output
        }
    }
}