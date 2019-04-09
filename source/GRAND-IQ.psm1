Set-StrictMode -Version 2.0
$BIGIQSession = $null

Get-ChildItem $PSScriptRoot\functions | ForEach-Object {
    . $_.fullname
}