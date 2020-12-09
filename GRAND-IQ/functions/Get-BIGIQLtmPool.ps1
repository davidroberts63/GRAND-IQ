function Get-BIGIQLtmPool {
    [CmdletBinding()]
    param(
        [string]
        $Partition = 'Common',

        [string]
        $PoolName,

        [switch]
        $ExpandMembers
    )

    $path = '/mgmt/tm/ltm/pool'
    if($PoolName) {
        $path += "/~$Partition~$PoolName"
    }

    $response = Invoke-BIGIQRestRequest -Path $path -Method get -ExpandSubCollections:$ExpandMembers.IsPresent

    GetItemsFromResponse -BigIQResponse $response -IncludeTotalCount | Write-Output
}

function Remove-BIGIQLtmPoolMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $PoolMember
    )

    $response = Invoke-BIGIQRestRequest -Link $PoolMember.selfLink -Method delete

    $response | Write-Output
}

function Add-BIGIQLtmPoolMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Pool,

        [Parameter(Mandatory)]
        $Node,

        [Parameter(Mandatory)]
        [int]
        $ServicePort
    )

    $member = @{
        name = $Node.name + ':' + $ServicePort
    }

    $response = Invoke-BIGIQRestRequest -Link $Pool.membersReference.link -method post -body $member

    $response | Write-Output
}

function Set-BIGIQLtmPoolMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $PoolMember
    )

    $response = Invoke-BIGIQRestRequest -Link $PoolMember.selfLink -method patch -body $PoolMember

    $response | Write-Output
}

function Enable-BIGIQLtmPoolMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $PoolMember
    )

    $patch = $PoolMember | Select-Object selfLink, state, session
    
    $patch.state = 'user-up'
    $patch.session = 'user-enabled'

    Set-BIGIQLtmPoolMember -PoolMember $patch | Write-Output
}

function Disable-BIGIQLtmPoolMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $PoolMember,

        [switch]
        $Force
    )

    $patch = $PoolMember | Select-Object selfLink, state, session
    
    if($Force) {
        $patch.state = 'user-down'
        $patch.session = 'user-disabled'
    } else {
        # State is allowing the continuation of existing connections.
        $patch.state = 'user-up'
        # While the session is disallowing new connections.
        $patch.session = 'user-disabled'
    }

    Set-BIGIQLtmPoolMember -PoolMember $patch | Write-Output
}
