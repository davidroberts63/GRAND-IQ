function Get-BIGIQLtmPool {
    <#
    .SYNOPSIS
    Get a pool from the local traffic management.
    
    .DESCRIPTION
    Get a pool from the local traffic management
    
    .PARAMETER Partition
    The partition the pool is in. Default is 'Common'.
    
    .PARAMETER PoolName
    The exact name of the pool to get.
    
    .PARAMETER ExpandMembers
    Indicates the cmdlet will expand the collection of pool members.
    
    .EXAMPLE
    Get-BIGIQLtmPool -PoolName 'somepool' -ExpandMembers
    #>
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
    <#
    .SYNOPSIS
    Removes a pool member.
    
    .DESCRIPTION
    Removes a pool member.
    
    .PARAMETER PoolMember
    The pool member object retrieved earlier having used pool members in a Get-BIGIQLtmPool response. Or the url to the pool member to remove.
    
    .EXAMPLE
    $pool = Get-BIGIQLtmPool -PoolName somepool -ExpandMembers
    Remove-BIGIQLtmPoolMember -PoolMember $pool.membersReference.items[0]

    $pool = Get-BIGIQLtmPool -PoolName somepool -ExpandMembers
    Remove-BIGIQLtmPoolMember -PoolMamber $pool.membersReference.items[0].selfLink
    
    .NOTES
    This uses the 'selfLink' property of the provided pool member object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $PoolMember
    )

    $uri = $null
    if($PoolMember -is [string] -and (([Uri]$PoolMember).AbsoluteUri)
    {
        $uri = $PoolMember
    } else {
        $uri = $PoolMember.selfLink
    }
    $response = Invoke-BIGIQRestRequest -Link $uri -Method delete

    $response | Write-Output
}

function Add-BIGIQLtmPoolMember {
    <#
    .SYNOPSIS
    Adds a node to an existing pool
    
    .DESCRIPTION
    Adds a node to an existing pool
    
    .PARAMETER Pool
    The pool object
    
    .PARAMETER Node
    The node object to be added to the pool.
    
    .PARAMETER ServicePort
    The network port the node responds to within the pool.

    #>
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
