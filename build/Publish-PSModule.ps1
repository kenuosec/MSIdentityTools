param
(
	#
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = ".\release\MSIdentityTools\1.0.1.0",
    #
    [Parameter(Mandatory=$true)]
    [string] $NuGetApiKey
)

Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey
