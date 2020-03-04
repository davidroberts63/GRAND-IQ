function Get-BIGIQLtmPool {
    [CmdletBinding()]
    param(
    )

    $response = Invoke-BIGIQRestRequest -path '/mgmt/tm/ltm/pool' -method get

    $response | Write-Output
}
