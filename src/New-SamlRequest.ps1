<#
.SYNOPSIS
   Create New Saml Request.
.EXAMPLE
    PS C:\>New-SamlRequest -Issuer 'urn:microsoft:adfs:claimsxray'
    Create New Saml Request for Claims X-Ray.
.INPUTS
    System.String
#>
function New-SamlRequest {
    [CmdletBinding()]
    [OutputType([xml],[string])]
    param (
        # Azure AD uses this attribute to populate the InResponseTo attribute of the returned response.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Issuer,
        # If provided, this parameter must match the RedirectUri of the cloud service in Azure AD.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $AssertionConsumerServiceURL,
        # If this is true, Azure AD will attempt to authenticate the user silently using the session cookie.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch] $IsPassive,
        # If true, it means that the user will be forced to re-authenticate, even if they have a valid session with Azure AD.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [switch] $ForceAuthn,
        # Deflate and Base64 Encode the Saml Request
        [Parameter(Mandatory = $false)]
        [switch] $DeflateAndEncode
    )

    begin {
        $pathSamlRequest = Join-Path $PSScriptRoot 'SamlRequest.xml'
    }

    process {
        $xmlSamlRequest = New-Object xml
        $xmlSamlRequest.Load($pathSamlRequest)
        $xmlSamlRequest.AuthnRequest.ID = 'id{0}' -f (New-Guid).ToString("N")
        $xmlSamlRequest.AuthnRequest.IssueInstant = (Get-Date).ToUniversalTime().ToString('o')
        $xmlSamlRequest.AuthnRequest.Issuer.'#text' = $Issuer
        $xmlSamlRequest.AuthnRequest.AssertionConsumerServiceURL = $AssertionConsumerServiceURL
        $xmlSamlRequest.AuthnRequest.IsPassive = $IsPassive.ToString().ToLowerInvariant()
        $xmlSamlRequest.AuthnRequest.ForceAuthn = $ForceAuthn.ToString().ToLowerInvariant()

        if ($DeflateAndEncode) {
            $EncodedSamlRequest = $xmlSamlRequest.OuterXml | Compress-Data | ConvertTo-Base64String
            Write-Output $EncodedSamlRequest
        }
        else {
            Write-Output $xmlSamlRequest
        }
    }
}
