<#
.SYNOPSIS
    Validate the digital signature for JSON Web Token.
.EXAMPLE
    PS C:\>Confirm-JsonWebTokenSignature $OpenIdConnectToken
    Validate the OpenId token was signed by token issuer based on the OIDC Provider Configuration for token issuer.
.EXAMPLE
    PS C:\>Confirm-JsonWebTokenSignature $AccessToken
    Validate the access token was signed by token issuer based on the OIDC Provider Configuration for token issuer.
.INPUTS
    System.String
#>
function Confirm-JsonWebTokenSignature {
    [CmdletBinding()]
    [Alias('Confirm-JwtSignature')]
    [OutputType([bool])]
    param (
        # JSON Web Signature (JWS)
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $InputObjects
    )

    process {
        foreach ($InputObject in $InputObjects) {
            $Jws = ConvertFrom-JsonWebSignature $InputObject
            $SigningKeys = $Jws.Payload.iss | Get-OpenIdProviderConfiguration -Keys | Where-Object use -eq 'sig'
            $SigningKey = $SigningKeys | Where-Object kid -eq $Jws.Header.kid
            $SigningCertificate = Get-X509Certificate $SigningKey.x5c

            Confirm-JsonWebSignature $InputObject -SigningCertificate $SigningCertificate
        }
    }
}
