<#
.SYNOPSIS
   Show Json Web Token (JWT) decoded in Web Browser.
.EXAMPLE
    PS C:\>$MsalToken.IdToken | Show-JsonWebToken
    Show OAuth IdToken JWT decoded in Web Browser.
.INPUTS
    System.String
#>
function Show-JsonWebToken {
    [CmdletBinding()]
    [Alias('Show-Jwt')]
    [OutputType([PSCustomObject])]
    param (
        # JSON Web Signature (JWS)
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $InputObjects
    )

    process {
        foreach ($InputObject in $InputObjects) {
            Start-Process "https://jwt.ms/#id_token=$InputObject"
        }
    }
}
