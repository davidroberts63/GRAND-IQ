function Invoke-BIGIQRestRequest {
    [CmdletBinding()]
    param(
        $path,
        $method,
        $requestParameters
    )

    $options = @{
        Uri = $Script:Session.rootUrl + $path
        Method = $method
        Headers = @{ 'X-F5-Auth-Token' = $Script:Session.token }
        Body = ConvertTo-Json $requestParameters -Compress
    }

    $response = Invoke-RestMethod @options -Verbose:$Verbose

    $response | Write-Output
}