
Import-Module ..\**\CommonFunctions.psm1

Remove-Module MSIdentityTools -ErrorAction SilentlyContinue
Import-Module ..\src\MSIdentityTools.psd1

### Parameters
[string] $TenantId = 'jasoth.onmicrosoft.com'
[uri] $RedirectUri = 'https://login.microsoftonline.com/common/oauth2/nativeclient'

### Test PublicClient
[string] $PublicClientId = 'fcbe5a30-c893-4df5-8176-e6d2b5fffff6'
[string[]] $DelegatedScopes = @(
    #'https://graph.microsoft.com/.default'
    'https://graph.microsoft.com/User.Read'
)

## Generate Client Application Object
$ApplicationOptions = New-Object Microsoft.Identity.Client.PublicClientApplicationOptions -Property @{
    TenantId = $TenantId
    ClientId = $PublicClientId
}
Invoke-RestMethodwithBearerAuth -Scopes $DelegatedScopes -Method Get -Uri 'https://graph.microsoft.com/v1.0/me' -ClientApplication $ApplicationOptions -Verbose

Invoke-RestMethodwithBearerAuth -Method Get -Uri 'https://graph.microsoft.com/v1.0/users' -ClientApplication $ApplicationOptions -Verbose


## Get Application and Users
$ClientApplication = Get-MsalClientApplication -ClientId $PublicClientId -TenantId $TenantId
Get-MsalAccount -ClientApplication $ClientApplication


### Test ConfidentialClient
[string] $ConfidentialClientId = 'e001258f-ee21-4c08-9205-9031a3a1cfbd'
[securestring] $ConfidentialClientSecret = Convertto-SecureString 'SuperSecretString' -AsPlainText -Force
[System.Security.Cryptography.X509Certificates.X509Certificate2] $ConfidentialClientCertificate = Get-Item Cert:\CurrentUser\My\b12afe95f226d94dd01d3f61ae3dbb1c4947ef62
[string[]] $ApplicationScopes = @(
    'https://graph.microsoft.com/.default'
    #'https://graph.microsoft.com/User.Read.All'
)

if ($MsalToken.AccessToken) {
    ## Create New Confidential Client?
    [string] $ConfidentialClientId = New-AzureADApplicationConfidentialClient $MsalToken | Select-Object -ExpandProperty appId
    ## Reset ClientSecret?
    [securestring] $ConfidentialClientSecret = Add-AzureADApplicationClientSecret $MsalToken $ConfidentialClientId
    ## Reset ClientCertificate?
    $ConfidentialClientCertificate = Add-AzureADApplicationClientCertificate $MsalToken $ConfidentialClientId
}

## Generate Client Application Object
(New-Object Microsoft.Identity.Client.ConfidentialClientApplicationOptions -Property @{
    TenantId = [guid]::NewGuid()
    ClientId = [guid]::NewGuid()
    ClientSecret = (ConvertFrom-SecureStringAsPlainText $ConfidentialClientSecret -Force)
} | New-MsalClientApplication -TenantId $TenantId -Verbose).AppConfig

## Test Confidential Client Secret
Get-MsalToken -ClientId $ConfidentialClientId -ClientSecret $ConfidentialClientSecret -TenantId $TenantId -Scopes $ApplicationScopes -Verbose
New-MsalClientApplication -ClientId $ConfidentialClientId -ClientSecret $ConfidentialClientSecret -TenantId $TenantId -Verbose | Get-MsalToken -Scopes $ApplicationScopes -Verbose
## Test Confidential Client Certificate (Not working for common endpoints)
Get-MsalToken -ClientId $ConfidentialClientId -ClientCertificate $ConfidentialClientCertificate -TenantId $TenantId -Scopes $ApplicationScopes -Verbose
New-MsalClientApplication -ClientId $ConfidentialClientId -ClientCertificate $ConfidentialClientCertificate -TenantId $TenantId -Verbose | Get-MsalToken -Scopes $ApplicationScopes -Verbose
## Test Confidential Client Certificate On Behalf Of
# Must Grant Admin Consent in Portal or create Service Principal
Start-Process "https://login.microsoftonline.com/$TenantId/adminconsent?client_id=$ConfidentialClientId&state=12345&redirect_uri=$([System.Net.WebUtility]::UrlEncode($RedirectUri))"
$MsalTokenImpersonation = Get-MsalToken -ClientId $PublicClientId -TenantId $TenantId -Scopes "$ConfidentialClientId/user_impersonation" -Verbose
Get-MsalToken -ClientId $ConfidentialClientId -ClientCertificate $ConfidentialClientCertificate -TenantId $TenantId -Scopes 'https://graph.microsoft.com/User.Read' -UserAssertion $MsalTokenImpersonation.AccessToken -Verbose


### Cleanup
## Clear Consent
Get-AzureADServicePrincipal -Filter "AppId eq '$PublicClientId'" | Get-AzureADServicePrincipalOAuth2PermissionGrant | Remove-AzureADOAuth2PermissionGrant

## Remove Certificates from Certificate Store
Get-ChildItem Cert:\CurrentUser\My | Where-Object Subject -eq "CN=ConfidentialClient" | Remove-Item
