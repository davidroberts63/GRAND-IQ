function Get-BIGIQLtmPool {
    [CmdletBinding()]
    param(
    )

    $response = Invoke-BIGIQRestRequest -path '/mgmt/tm/ltm/pool' -method get

    $response | Write-Output
}

function Get-BIGIQLtmPolicy {
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

function New-BIGIQLtmPolicy {
    [CmdletBinding()]
    param(
        [String]$Name,
        [String]$Description,
        [String]$StrategyId,
        [String]$Partition = 'Common',
        [hashtable]$ExtraProperties
    )

    $body = @{
        name = $Name
        description = $Description
        partition = $Partition
        strategy = $StrategyId
    } + $ExtraProperties

    $response = Invoke-BIGIQRestRequest -Path '/mgmt/tm/ltm/policy' -Method Post -Body $body

    $response | Write-Output
}

function Remove-BIGIQLtmPolicy {
    [CmdletBinding()]
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

    $options = @{
        Path = $path
        Method = 'Delete'
    }

    Invoke-BIGIQRestRequest @options
}