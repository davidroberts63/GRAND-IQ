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
