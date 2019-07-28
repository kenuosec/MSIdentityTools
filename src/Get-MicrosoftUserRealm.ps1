<#
.SYNOPSIS
   Get User Realm Information for a Microsoft user account.
.EXAMPLE
   Get-MicrosoftUserRealm user@domain.com
.EXAMPLE
   'user1@domainA.com','user2@domainA.com','user@domainB.com' | Get-MicrosoftUserRealm
#>
function Get-MicrosoftUserRealm {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string[]] $Users,
        #
        [Parameter(Mandatory=$false)]
        [string] $ApiVersion = '2.1'
    )

    process {
        foreach ($User in $Users) {
            $uriUserRealm = New-Object System.UriBuilder 'https://login.microsoftonline.com/common/userrealm'
            $uriUserRealm.Query = ConvertTo-QueryString @{
                'api-version' = $ApiVersion
                'user' = $User
            }

            $Result = Invoke-RestMethod -Method Get -Uri $uriUserRealm.Uri.AbsoluteUri
            return $Result
        }
    }
}
