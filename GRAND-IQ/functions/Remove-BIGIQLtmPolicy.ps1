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