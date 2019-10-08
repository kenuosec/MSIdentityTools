<#
.SYNOPSIS

.EXAMPLE
    PS C:\>Get-MicrosoftIdpAuthority -TenantId tenant.onmicrosoft.com | Get-SamlFederationMetadata
    Get SAML or WS-Fed Federation Metadata for a specific Microsoft tenant.
.EXAMPLE
    PS C:\>Get-SamlFederationMetadata 'https://accounts.google.com/'
    Get SAML or WS-Fed Federation Metadata for Google Accounts.
.INPUTS
    System.Uri
#>
function Get-SamlFederationMetadata {
    [CmdletBinding()]
    [Alias('Get-WsFedFederationMetadata')]
    [OutputType([xml],[System.Xml.XmlElement[]])]
    param (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [uri] $Issuer,
        # Azure AD Application Id
        [Parameter(Mandatory=$false, Position=2)]
        [guid] $AppId
    )
    $uriFederationMetadata = New-Object System.UriBuilder $Issuer.AbsoluteUri
    $uriFederationMetadata.Path += '/FederationMetadata/2007-06/FederationMetadata.xml'
    if ($AppId) { $uriFederationMetadata.Query = ConvertTo-QueryString @{
            AppId = $AppId
        }
    }
    $FederationMetadata = Invoke-RestMethod -Uri $uriFederationMetadata.Uri.AbsoluteUri -ContentType 'application/samlmetadata+xml'
    if ($FederationMetadata -is [string]) {
        #[xml] $FederationMetadata = $FederationMetadata.Substring(1)
        [xml] $FederationMetadata = $FederationMetadata.Trim('﻿')
    }

    return $FederationMetadata.GetElementsByTagName('EntityDescriptor')
}
