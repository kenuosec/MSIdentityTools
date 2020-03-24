<#
.SYNOPSIS
    Request tokens using MSAL.PS Module for use with AzureAD or AzureADPreview Modules. This allows FIDO2 credentials to be used for authentication (on supported OS and browser).
.EXAMPLE
    PS C:\>Connect-AzureAdWithCustomApp '00000000-0000-0000-0000-000000000000'
    Use registered client application to connect to AzureAD module.
.INPUTS
    System.String
#>
function Connect-AzureAdWithCustomApp {
    [CmdletBinding(DefaultParameterSetName='PublicClient')]
    #[OutputType([Microsoft.Open.Azure.AD.CommonLibrary.PSAzureContext])]
    param (
        # Specifies the client application or client application options to use for authentication.
        [Parameter(Mandatory=$true, ParameterSetName='InputObject', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [object] $ClientApplication,
        # Identifier of the client requesting the token.
        [Parameter(Mandatory=$true, ParameterSetName='PublicClient', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(Mandatory=$true, ParameterSetName='ConfidentialClientCertificate', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ClientId,
        # Client assertion certificate of the client requesting the token.
        [Parameter(Mandatory=$true, ParameterSetName='ConfidentialClientCertificate', ValueFromPipelineByPropertyName=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate,
        # Instance of Azure Cloud
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Microsoft.Identity.Client.AzureCloudInstance] $AzureEnvironmentName = ([Microsoft.Identity.Client.AzureCloudInstance]::None),
        # Tenant identifier of the authority to issue token. It can also contain the value "consumers" or "organizations".
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $TenantId,
        # Scopes required by AzureAD PowerShell Module for AAD Graph
        [Parameter(Mandatory=$false, ParameterSetName='PublicClient', ValueFromPipelineByPropertyName=$true)]
        [string[]] $AadGraphScopes = 'https://graph.windows.net/Directory.AccessAsUser.All',
        # Scopes required by AzureAD PowerShell Module for MS Graph
        [Parameter(Mandatory=$false, ParameterSetName='PublicClient', ValueFromPipelineByPropertyName=$true)]
        [string[]] $MsGraphScopes = @(
            'https://graph.microsoft.com/AuditLog.Read.All'
            'https://graph.microsoft.com/Directory.AccessAsUser.All'
            'https://graph.microsoft.com/Directory.ReadWrite.All'
            'https://graph.microsoft.com/Group.ReadWrite.All'
            'https://graph.microsoft.com/IdentityProvider.ReadWrite.All'
            'https://graph.microsoft.com/Policy.ReadWrite.TrustFramework'
            'https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureAD'
            'https://graph.microsoft.com/PrivilegedAccess.ReadWrite.AzureResources'
            'https://graph.microsoft.com/TrustFrameworkKeySet.ReadWrite.All'
            'https://graph.microsoft.com/User.Invite.All'
        )
    )

    begin {
        $PSModule = Install-AzureAdModule -ErrorAction Stop
        Import-Module -ModuleInfo $PSModule -ErrorAction Stop
    }

    process {
        ## Create Client Application
        switch ($PSCmdlet.ParameterSetName) {
            'InputObject' {
                [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = Resolve-MsalClientApplication $ClientApplication
                break
            }
            'PublicClient' {
                [Microsoft.Identity.Client.IPublicClientApplication] $MsalClientApplication = Select-MsalClientApplication -ClientId $ClientId -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -RedirectUri 'http://localhost'
                break
            }
            'ConfidentialClientCertificate' {
                [Microsoft.Identity.Client.IConfidentialClientApplication] $MsalClientApplication = Select-MsalClientApplication -ClientId $ClientId -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -ClientCertificate $ClientCertificate
                break
            }
        }

        ## Get Tokens for Connect-AzureAD command
        if ($MsalClientApplication -is [Microsoft.Identity.Client.IPublicClientApplication]) {
            $AadGraphToken = Get-MsalToken $MsalClientApplication -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -Scopes $AadGraphScopes -ExtraScopesToConsent $MsGraphScopes -UseEmbeddedWebView:$false -Interactive -ErrorAction Stop
            $MsGraphToken = Get-MsalToken $MsalClientApplication -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -Scopes $MsGraphScopes -UseEmbeddedWebView:$false -ErrorAction Stop
            Connect-AzureAD -TenantId $AadGraphToken.TenantId -AadAccessToken $AadGraphToken.AccessToken -MsAccessToken $MsGraphToken.AccessToken -AccountId $AadGraphToken.Account.Username
        }
        else {
            Write-Warning 'Using a confidential client is non-interactive requires that the necessary scopes/permissions be added to the application or have permissions on-behalf-of a user.'
            $AadGraphToken = Get-MsalToken $MsalClientApplication -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -Scopes 'https://graph.windows.net/.default' -ErrorAction Stop
            $MsGraphToken = Get-MsalToken $MsalClientApplication -AzureCloudInstance $AzureEnvironmentName -TenantId $TenantId -Scopes 'https://graph.microsoft.com/.default' -ErrorAction Stop
            $JwtPayload = Expand-JsonWebTokenPayload $AadGraphToken.AccessToken
            Connect-AzureAD -TenantId $JwtPayload.tid -AadAccessToken $AadGraphToken.AccessToken -MsAccessToken $MsGraphToken.AccessToken -AccountId $JwtPayload.sub
        }
        Write-Warning ('Because this command connects the AzureAD module by obtaining access tokens outside the module itself, the AzureAD module commands cannot automatically refresh the tokens when they expire or are revoked. To maintain access, this command must be run again when the current token expires at "{0:t}".' -f [System.DateTimeOffset]::FromUnixTimeSeconds((Expand-JsonWebTokenPayload $AadGraphToken.AccessToken).exp).ToLocalTime())
    }
}
