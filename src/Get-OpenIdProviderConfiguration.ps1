<#
.SYNOPSIS

.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId tenant.onmicrosoft.com | Get-OpenIdProviderConfiguration
    Get OpenId Provider Configuration for a specific Microsoft tenant.
.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId tenant.onmicrosoft.com | Get-OpenIdProviderConfiguration -Keys
    Get public keys for OpenId Provider for a specific Microsoft tenant.
.EXAMPLE
    PS C:\>Get-OpenIdProviderConfiguration 'https://accounts.google.com/'
    Get OpenId Provider Configuration for Google Accounts.
.INPUTS
    System.Uri
#>
function Get-OpenIdProviderConfiguration {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [uri] $Issuer,
        #
        [Parameter(Mandatory=$false)]
        [switch] $Keys
    )
    $uriOpenIdProviderConfiguration = New-Object System.UriBuilder $Issuer.AbsoluteUri
    $uriOpenIdProviderConfiguration.Path += '/.well-known/openid-configuration'
    $OpenIdProviderConfiguration = Invoke-RestMethod -Uri $uriOpenIdProviderConfiguration.Uri.AbsoluteUri
    if ($Keys) {
        $OpenIdProviderConfigurationJwks = Invoke-RestMethod -Uri $OpenIdProviderConfiguration.jwks_uri
        return $OpenIdProviderConfigurationJwks.keys
    }
    else {
        return $OpenIdProviderConfiguration
    }

}
