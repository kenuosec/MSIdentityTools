<#
.SYNOPSIS
   Get User Credential Type Information for a Microsoft user account.
.EXAMPLE
   Get-MsftCredentialType user@domain.com
.EXAMPLE
   'user1@domainA.com','user2@domainA.com','user@domainB.com' | Get-MsftCredentialType
#>
function Get-MsftCredentialType {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        # Usernames
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [string[]] $Usernames,
        # Market Region
        [Parameter(Mandatory = $false)]
        [string] $Market = 'en-US'
    )

    process {
        foreach ($Username in $Usernames) {
            $uriUserRealm = New-Object System.UriBuilder 'https://login.microsoftonline.com/common/GetCredentialType'
            $uriUserRealm.Query = ConvertTo-QueryString @{
                'mkt' = $Market
            }

            $Result = Invoke-RestMethod -UseBasicParsing -Method Post -Uri $uriUserRealm.Uri.AbsoluteUri -ContentType 'application/json; charset=UTF-8' -Body (ConvertTo-Json @{
                    username = $Username
                    # isOtherIdpSupported            = $true
                    # checkPhones                    = $false
                    # isRemoteNGCSupported           = $true
                    # isCookieBannerShown            = $false
                    # isFidoSupported                = $true
                    # country                        = 'US'
                    # forceotclogin                  = $false
                    # isExternalFederationDisallowed = $false
                    # isRemoteConnectSupported       = $false
                    # federationFlags                = 0
                    # isSignup                       = $false
                    # isAccessPassSupported          = $true
                })
            Write-Output $Result
        }
    }
}
