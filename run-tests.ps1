[CmdletBinding()]
param(
    [Switch]$IncludeCodeCoverage
)

Write-Host 'Verifying Pester is available...'
$pester = Get-Module -ListAvailable Pester -ErrorAction SilentlyContinue | Sort-Object Version | Select-Object -Last 1
if(-not $pester) {
    Write-Warning "Could not find the Pester Powershell module. 'Install-Module Pester -Force -SkipPublisherCheck' first."
    exit 1
} elseif($pester.Version.Major -lt 4) {
    Write-Warning "Pester 4.0 and greater is required. 'Install-Module Pester -Force -SkipPublisherCheck' first."
    exit 2
}

Import-Module Pester -ErrorAction SilentlyContinue

Write-Host 'Running Pester...'
$pesterOptions = @{
    PassThru = $true
    OutputFile = "$PSScriptRoot\tests-results.xml"
    OutputFormat = 'NUnitXML'
}

if($IncludeCodeCoverage) {
    $pesterOptions += @{
        CodeCoverage = "$PSScriptRoot\GRAND-IQ\functions\*"
        CodeCoverageOutputFile = "$PSScriptRoot\coverage-results.xml"
        CodeCoverageOutputFileFormat = 'JaCoCo'
    }
}
Invoke-Pester @pesterOptions | Out-Null
