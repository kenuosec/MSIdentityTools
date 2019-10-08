<#
.SYNOPSIS
   Get Tenant Discovery Instance Information for a Microsoft Identity Provider Endpoint.
.EXAMPLE
   Get-MsftTenantDiscoveryInstance https://login.windows.net/common/oauth2/v2.0/authorize
.EXAMPLE
   'https://login.windows.net/common/oauth2/v2.0/authorize','user2@domainA.com' | Get-MsftTenantDiscoveryInstance
#>
function Get-MsftTenantDiscoveryInstance {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        #
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [string[]] $AuthorizationEndpoints,
        # API Version
        [Parameter(Mandatory=$false)]
        [string] $ApiVersion = '1.1'
    )

    process {
        foreach ($AuthorizationEndpoint in $AuthorizationEndpoints) {
            $uriDiscoverInstance = New-Object System.UriBuilder 'https://login.microsoftonline.com/common/discovery/instance'
            $uriDiscoverInstance.Query = ConvertTo-QueryString @{
                'api-version' = $ApiVersion
                'authorization_endpoint' = $AuthorizationEndpoint
            }

            $Result = Invoke-RestMethod -Method Get -Uri $uriDiscoverInstance.Uri.AbsoluteUri
            Write-Output $Result
        }
    }
}
