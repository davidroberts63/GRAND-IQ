function Get-BIGIQLtmStats {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Item
    )

    $link = if($Item.PSObject.Properties.Name -contains "selfLink") { $item.selfLink } else { $item.link }
    $uriBuilder = CreateUriBuilder -RootUri $BIGIQSession.rootUri -Link $link
    $uriBuilder.Path += '/stats'

    $response = Invoke-BIGIQRestRequest -Link $uriBuilder.Uri.ToString() -Method get

    # Return the nested entries as top level objects.
    $entries = $response.entries.PSObject.Properties | ForEach-Object {
        $response.entries."$($_.Name)".nestedStats | Write-Output
    }

    $entries | Write-Output
}