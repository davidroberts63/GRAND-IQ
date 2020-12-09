function Get-BIGIQLtmNode {
    <#<#
    .SYNOPSIS
    Gets nodes
    
    .DESCRIPTION
    Gets the collection of nodes
    
    .EXAMPLE
    Get-BIGIQLtmNode
    
    .NOTES
    General notes
    #>#>
    [CmdletBinding()]
    param(
    )

    $response = Invoke-BIGIQRestRequest -Path '/mgmt/tm/ltm/node' -Method get

    GetItemsFromResponse -BigIQResponse $response -IncludeTotalCount | Write-Output
}
