function Invoke-BIGIQRestRequest {
    [CmdletBinding(SupportsShouldProcess, SupportsPaging)]
    param(
        $Path,
        $Method = 'GET',
        [Alias('Body')]
        $RequestParameters,
        $SessionToken # Might want to switch this to a WebSession object.
    )

    process {
        if(-not $SessionToken) {
            $SessionToken = $BIGIQSession.token
        }

        $uriBuilder = CreateUriBuilder -rootUrl $BIGIQSession.rootUrl -path $Path -first $PSCmdlet.PagingParameters.First -skip $PSCmdlet.PagingParameters.Skip

        # Build out the parameters for the Invoke-RestMethod
        # TODO: Add ability to add other Invoke-RestMethod parameters. Though this would be leaky if the way of calling is ever changed.
        $options = @{
            Uri = $uriBuilder.Uri
            Method = $method
            Headers = @{ 'X-F5-Auth-Token' = $SessionToken; 'Content-Type' = 'application/json' } # TODO: Add ability to add custom headers
            Body = ConvertTo-Json $requestParameters -Compress
        }

        Write-Verbose 'Request body:'
        $options.Body | Write-Verbose
        if($PSCmdlet.ShouldProcess($Path)) {
            Invoke-RestMethod @options | Write-Output
        }
    }
}

function GetItemsFromResponse {
    param(
        [Object]$bigIQResponse,
        [Boolean]$includeTotalCount
    )

    $result = $bigIQResponse

    # Handles where it has multiple items in the response.
    if($bigIQResponse.PSObject.Properties.Name -contains 'items') {
        $result = $response.items

        if($includeTotalCount) {
            Write-Verbose 'Adding item count information'
            $totalCount = $bigIQResponse.items.Count # If all items were returned in a single request (no paging) simply use the count of items.
            if($bigIQResponse.PSObject.Properties.Name -contains 'totalItems') {
                $totalCount = $bigIQResponse.totalItems
            }

            Add-Member -InputObject $result -NotePropertyName TotalCount -NotePropertyValue $totalCount
        }
    } else {
        # Otherwise, this is a single item response. So no paging information to add.
    }

    Write-Output $result -NoEnumerate:$includeTotalCount # NoEnumerate prevents PowerShell from unwrapping the array, thus losing that 'TotalCount' property.
}

function CreateUriBuilder {
    param(
        [String]$rootUrl,
        [String]$path,
        [UInt64]$first,
        [UInt64]$skip
    )

    # Build out the query string for paging the results.
    $uriBuilder = New-Object System.UriBuilder($rootUrl)
    $uriBuilder.Path = $path # What if the device is access via a subpath, like a virtual app in IIS? THis would break that.

    $query = [System.Web.HttpUtility]::ParseQueryString($uriBuilder.Query)

    if($first -eq [UInt64]::MaxValue) { $first = $null }
    if($skip -eq 0) { $skip = $null }

    if($first) {
        $query['$top'] = [int]($first)
    }
    if($skip) {
        $query['$skip'] = [int]($skip)
    }
    $uriBuilder.Query = $query.ToString()

    return $uriBuilder
}