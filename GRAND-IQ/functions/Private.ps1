function GetItemsFromResponse {
    param(
        [Object]$bigIQResponse,

        [switch]
        $includeTotalCount
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
        [System.Uri]$rootUri,
        [String]$Path,
        [String]$Link,
        [String]$Filter,
        [String]$Select,
        [UInt64]$skip,
        [UInt64]$first,
        [switch]$ExpandSubCollections
    )

    if($Link) {
        $uri = New-Object System.Uri($Link)
        $Path = $uri.PathAndQuery
    }

    # Build out the query string for paging the results.
    $uriBuilder = New-Object System.UriBuilder($rootUri.ToString() + $path)
    $query = [System.Web.HttpUtility]::ParseQueryString($uriBuilder.Query)

    if($first -eq [UInt64]::MaxValue) { $first = $null }
    if($skip -eq 0) { $skip = $null }

    if($Filter) {
        $query['$filter'] = $Filter
    }
    if($Select) {
        $query['$select'] = $Select
    }

    if($first) {
        $query['$top'] = [int]($first)
    }
    if($skip) {
        $query['$skip'] = [int]($skip)
    }
    if($ExpandSubCollections) {
        $query['expandSubcollections'] = 'true'
    }
    
    $query.Remove('ver') # Seems BIG-IP/IQ REST api has a problem when actually specifying the version in query string.
    $uriBuilder.Query = $query.ToString()

    return $uriBuilder
}