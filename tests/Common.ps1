$ModuleManifestPath = "$PSScriptRoot\..\source\GRAND-IQ.psd1"

# -Scope Global is needed when running tests from inside of psake, otherwise
# the module's functions cannot be found in the Plaster\ namespace
Import-Module $ModuleManifestPath -Global -PassThru
