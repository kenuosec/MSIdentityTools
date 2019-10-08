<#
.SYNOPSIS
   Get list of Microsoft IdPs containing account with specific email address.
.EXAMPLE
   Get-MsftUserIdPs user@domain.com
.EXAMPLE
   'user1@domainA.com','user2@domainA.com','user@domainB.com' | Get-MsftUserIdPs
#>
function Get-MsftUserIdPs {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string[]] $EmailAddresses,
        # API Version
        [Parameter(Mandatory=$false)]
        [string] $ApiVersion = 'v2.1'
    )

    process {
        foreach ($EmailAddress in $EmailAddresses) {
            $uriIdP = New-Object System.UriBuilder "https://odc.officeapps.live.com/odc/$ApiVersion/idp"
            $uriIdP.Query = ConvertTo-QueryString @{
                'hm' = 0
                'emailAddress' = $EmailAddress
            }

            $Result = Invoke-RestMethod -Method Get -Uri $uriIdP.Uri.AbsoluteUri
            Write-Output $Result
        }
    }
}
