function Get-BIGIQLtmPolicy {
    <#
    .SYNOPSIS
    Get policies
    
    .DESCRIPTION
    Get policies or the specified named policy.
    
    .PARAMETER Partition
    The partition to get the policy or policies from.
    
    .PARAMETER Name
    The name of a specific policy to get. If not specified returns all policies in the partition.
    
    .PARAMETER IsDraft
    Get the draft form of the policy if available.
    
    .EXAMPLE
    Get-BIGIQLtmPolicy -Name 'test_policy'
    
    .NOTES
    Paging is also supported and will be translated to the BIG-IP/BIG-IQ $skip and $top parameters.
    #>
    [CmdletBinding(SupportsPaging)]
    param(
        [Parameter(ParameterSetName='ByName')]
        [String]$Partition = 'Common',

        [Parameter(ParameterSetName='ByName')]
        [String]$Name,

        [Parameter(ParameterSetName='ByName')]
        [Switch]$IsDraft
    )

    $path = '/mgmt/tm/ltm/policy'

    if($PSCmdlet.ParameterSetName -eq 'ByName') {
        $path += "/~$Partition~"

        if($IsDraft) {
            $path += "Drafts~"
        }
        $path += $Name
    }

    $includeTotalCount = $PSCmdlet.PagingParameters -and $PSCmdlet.PagingParameters.IncludeTotalCount
    $options = @{
        Path = $path
        Method = 'Get'
        First = $PSCmdlet.PagingParameters.First
        Skip = $PSCmdlet.PagingParameters.Skip
        IncludeTotalCount = $includeTotalCount
    }
    $response = Invoke-BIGIQRestRequest @options
    $result = GetItemsFromResponse -bigIQResponse $response -includeTotalCount $includeTotalCount

    Write-Output $result -NoEnumerate:$includeTotalCount # NoEnumerate prevents PowerShell from unwrapping the array, thus losing that 'TotalCount' property.
}
