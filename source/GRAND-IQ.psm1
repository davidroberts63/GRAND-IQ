Set-StrictMode -Version 2.0

$BIGIQSession = New-Object PSCustomObject -Property @{
    rootUrl = $null
    authResponse = $null
    token = $null
}

Get-ChildItem $PSScriptRoot\functions | ForEach-Object {
    . $_.fullname
}