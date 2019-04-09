function Invoke-BIGIQRestRequest {
    [CmdletBinding()]
    param(
        $path,
        $method,
        $requestParameters
    )

    $options = @{
        Uri = $BIGIQSession.rootUrl + $path
        Method = $method
        Headers = @{ 'X-F5-Auth-Token' = $BIGIQSession.token }
        Body = ConvertTo-Json $requestParameters -Compress
    }

    $response = Invoke-RestMethod @options

    $response | Write-Output
}