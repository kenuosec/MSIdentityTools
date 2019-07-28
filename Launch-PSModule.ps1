param
(
    #
    [parameter(Mandatory=$false)]
    [string] $ModuleManifestPath = ".\src\MSIdentityTools.psd1"
)

.\build\Restore-NugetPackages.ps1 -BaseDirectory ".\" -Verbose:$false
Import-Module $ModuleManifestPath
