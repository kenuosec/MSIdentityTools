<#
.SYNOPSIS
   Invoke Saml Request on Azure AD.
.EXAMPLE
    PS C:\>$samlRequest = New-SamlRequest -Issuer 'urn:microsoft:adfs:claimsxray'
    PS C:\>Invoke-SamlRequest $samlRequest.OuterXml
    Create new Saml Request for Claims X-Ray and Invoke on Azure AD.
.INPUTS
    System.String
#>
function Invoke-SamlRequest {
    [CmdletBinding()]
    [OutputType()]
    param (
        # SAML Request
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]] $InputObjects,
        # Azure AD Tenant Id
        [Parameter(Mandatory = $false)]
        [string] $TenatId = 'common'
    )

    process {
        foreach ($InputObject in $InputObjects) {
            $xmlSamlRequest = ConvertFrom-SamlSecurityToken $InputObjects
            $EncodedSamlRequest = $xmlSamlRequest.OuterXml | Compress-Data | ConvertTo-Base64String

            [System.UriBuilder] $uriAzureAD = 'https://login.microsoftonline.com/{0}/saml2' -f $TenatId
            $uriAzureAD.Query = ConvertTo-QueryString @{
                SAMLRequest = $EncodedSamlRequest
            }

            Start-Process $uriAzureAD.Uri.AbsoluteUri
        }
    }
}
