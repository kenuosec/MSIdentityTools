<#
.SYNOPSIS
    Query Azure AD Graph API
.EXAMPLE
    PS C:\>Invoke-AzureAdGraphQuery -ClientApplication '00000000-0000-0000-0000-000000000000' -Scopes 'User.ReadBasic.All' -RelativeUri 'users'
    Return query results for first page of users.
.EXAMPLE
    PS C:\>Invoke-AzureAdGraphQuery -ClientApplication '00000000-0000-0000-0000-000000000000' -TenantId tenant.onmicrosoft.com -Scopes 'User.ReadBasic.All' -RelativeUri 'users' -ApiVersion beta -ReturnAllResults
    Return query results for all users in tenant.onmicrosoft.com using the beta API.
#>
function Invoke-AzureAdGraphQuery {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        # Specifies the client application or client application options to use for authentication.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object] $ClientApplication,
        # Specifies the scopes to request when getting an access token.
        [Parameter(Mandatory = $false)]
        [string[]] $Scopes,
        # Forces a fresh authentication by creating a new TokenCache instance.
        [Parameter(Mandatory = $false)]
        [switch] $NewTokenCache,
        # Tenant identifier for query.
        [Parameter(Mandatory = $false)]
        [string] $TenantId = 'myorganization',
        # Graph endpoint such as "users".
        [Parameter(Mandatory = $true)]
        [string] $RelativeUri,
        # Parameters such as "$top".
        [Parameter(Mandatory = $false)]
        [hashtable] $QueryParameters,
        # API Version.
        [Parameter(Mandatory = $false)]
        [ValidateSet('1.5', '1.6', 'beta')]
        [string] $ApiVersion = '1.6',
        # If results exceed a single page, request additional pages to get all data.
        [Parameter(Mandatory = $false)]
        [switch] $ReturnAllResults,
        # Base URL for Azure AD Graph API.
        [Parameter(Mandatory = $false)]
        [uri] $GraphBaseUri = 'https://graph.windows.net/'
    )

    $MsalClientApplication = Resolve-MsalClientApplication $ClientApplication -NewTokenCache:$NewTokenCache

    [hashtable] $paramInvokeRestMethod = @{
        ClientApplication = $MsalClientApplication
        UseBasicParsing   = $true
    }
    if ($Scopes) {
        for ($i = 0; $i -lt $Scopes.Count; $i++) {
            if ($Scopes[$i] -notlike ("*{0}*" -f $GraphBaseUri.Host)) {
                $Scopes[$i] = $GraphBaseUri.AbsoluteUri + $Scopes[$i]
            }
        }
        $paramInvokeRestMethod.Add('Scopes', $Scopes)
    }

    $uriQueryEndpoint = New-Object System.UriBuilder -ArgumentList ([IO.Path]::Combine($GraphBaseUri.AbsoluteUri, $TenantId, $RelativeUri))

    if (!$QueryParameters) {
        if ($uriQueryEndpoint.Query) { [hashtable] $QueryParameters = ConvertFrom-QueryString $uriQueryEndpoint.Query -AsHashtable }
        else { [hashtable] $QueryParameters = @{ } }
    }
    if (!$QueryParameters.ContainsKey('api-version')) { $QueryParameters.Add('api-version', $ApiVersion) }
    $uriQueryEndpoint.Query = ConvertTo-QueryString $QueryParameters

    ## Get results
    $results = Invoke-RestMethodWithBearerAuth -Method Get -Uri $uriQueryEndpoint.Uri.AbsoluteUri @paramInvokeRestMethod
    Write-Output $results

    if ($ReturnAllResults) {
        while ($results.PSObject.Properties['odata.nextLink'] -or $results.PSObject.Properties['@odata.nextLink']) {
            [string] $nextLink = $null
            if ($results.PSObject.Properties['odata.nextLink']) { $nextLink = [IO.Path]::Combine($GraphBaseUri.AbsoluteUri, $TenantId, $results.'odata.nextLink') }
            elseif ($results.PSObject.Properties['@odata.nextLink']) { $nextLink = $results.'@odata.nextLink' }

            $uriQueryEndpoint = New-Object System.UriBuilder -ArgumentList $nextLink
            if ($results.PSObject.Properties['odata.nextLink']) { $uriQueryEndpoint.Query = ConvertTo-QueryString ((ConvertFrom-QueryString $uriQueryEndpoint.Query -AsHashtable) + $QueryParameters) }
            $results = Invoke-RestMethodWithBearerAuth -Method Get -Uri $uriQueryEndpoint.Uri.AbsoluteUri @paramInvokeRestMethod
            Write-Output $results
        }
    }
}
