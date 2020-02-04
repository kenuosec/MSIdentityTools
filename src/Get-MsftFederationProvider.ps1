<#
.SYNOPSIS
   Get Federation endpoints for Microsoft Identity Providers.
.EXAMPLE
   Get-MsftFederationProvider domain.com
.EXAMPLE
   'domainA.com','domainB.com' | Get-MsftFederationProvider
#>
function Get-MsftFederationProvider {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string[]] $Domains,
        # API Version
        [Parameter(Mandatory=$false)]
        [string] $ApiVersion = 'v2.1'
    )

    process {
        foreach ($Domain in $Domains) {
            $uriFederationProvider = New-Object System.UriBuilder "https://odc.officeapps.live.com/odc/$ApiVersion/federationProvider"
            $uriFederationProvider.Query = ConvertTo-QueryString @{
                'domain' = $Domain
            }

            $Result = Invoke-RestMethod -UseBasicParsing -Method Get -Uri $uriFederationProvider.Uri.AbsoluteUri
            Write-Output $Result
        }
    }
}
