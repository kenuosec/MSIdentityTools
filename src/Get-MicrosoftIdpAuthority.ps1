<#
.SYNOPSIS
    Build Microsoft Identity Authority URI
.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority
    Get common Microsoft authority URI endpoint.
.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId consumers
    Get consumer Microsoft authority URI endpoint.
.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId domain.com
    Get specific Microsoft tenant authority URI endpoint.
.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId 00000000-0000-0000-0000-000000000000 -Policy B2CSignUp
    Get specific Microsoft B2C tenant authority URI endpoint for B2CSignUp policy.
#>
function Get-MicrosoftIdpAuthority {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param (
        #
        [Parameter(Mandatory=$false, Position=1)]
        [uri] $BaseUri = "https://login.microsoftonline.com/",
        #
        [Parameter(Mandatory=$false, Position=2)]
        [string] $TenantId = "common",
        #
        [Parameter(Mandatory=$false, Position=3)]
        [ValidateSet('v1.0','v2.0')]
        [string] $Version = 'v2.0',
        #
        [Parameter(Mandatory=$false, Position=4)]
        [string] $Policy
    )
    $uriAzureADAuthority = New-Object System.UriBuilder $BaseUri.AbsoluteUri
    $uriAzureADAuthority.Path = '/{0}' -f $TenantId
    if ($Version -ne 'v1.0') { $uriAzureADAuthority.Path += '/{0}' -f $Version }
    if ($Policy) { $uriAzureADAuthority.Query = ConvertTo-QueryString @{ p = $Policy } }
    return $uriAzureADAuthority.Uri.AbsoluteUri
}
