param
(
	#
    [parameter(Mandatory=$false)]
    [string] $ModulePath = ".\release\MSIdentityTools\1.0.0.3",
    #
    [parameter(Mandatory=$true)]
    [string] $NuGetApiKey
)

Publish-Module -Path $ModulePath -NuGetApiKey $NuGetApiKey
