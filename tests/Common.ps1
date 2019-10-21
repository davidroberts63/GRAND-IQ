$ErrorActionPreference = 'STOP'

$ModuleManifestPath = "$PSScriptRoot\..\GRAND-IQ\GRAND-IQ.psd1"

# -Scope Global is needed when running tests from inside of psake, otherwise
# the module's functions cannot be found in the Plaster\ namespace
Get-Module GRAND-IQ | Remove-Module -Force
Import-Module $ModuleManifestPath -Global
