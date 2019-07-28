<#
.SYNOPSIS
   Extract Json Web Token (JWT) from JWS structure to PowerShell object.
.EXAMPLE
    PS C:\>$MsalToken.IdToken | Convert-JsonWebToken
    Convert OAuth IdToken JWS to PowerShell object.
.INPUTS
    System.String
#>
function Convert-JsonWebTokenPayload {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        # JSON Web Signature (JWS)
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $InputObject
    )
    [string] $JwsPayload = $InputObject.Split('.')[1]
    $JwtDecoded = $JwsPayload | ConvertFrom-Base64String -Base64Url | ConvertFrom-Json
    return $JwtDecoded
}
