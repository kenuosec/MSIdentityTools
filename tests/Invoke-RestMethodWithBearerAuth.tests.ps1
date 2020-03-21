[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1"
)

Import-Module $ModulePath -Force

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

## Get Test Automation Token
[hashtable] $AppConfigAutomation = @{
    ClientId = 'ada4b466-ae54-45f8-98fc-13b22708b978'
    ClientCertificate = (Get-ChildItem Cert:\CurrentUser\My\7103A1080D8611BD2CE8A5026D148938F787B12C)
    RedirectUri = 'http://localhost/'
    TenantId = 'jasoth.onmicrosoft.com'
}
$MSGraphToken = Get-MSGraphToken -ErrorAction Stop @AppConfigAutomation

try {
    ## Create applications in tenant for testing.
    $appPublicClient,$spPublicClient = New-TestAzureAdPublicClient -AdminConsent -MSGraphToken $MSGraphToken
    $appConfidentialClient,$spConfidentialClient = New-TestAzureAdConfidentialClient -AdminConsent -MSGraphToken $MSGraphToken
    $appConfidentialClientSecret,$ClientSecret = $appConfidentialClient | Add-AzureAdClientSecret -MSGraphToken $MSGraphToken
    $appConfidentialClientCertificate,$ClientCertificate = $appConfidentialClient | Add-AzureAdClientCertificate -MSGraphToken $MSGraphToken
    $StartDelay = Get-Date

    ## Add delay to allow time for application configuration and credentials to propogate.
    $RemainingDelay = New-Timespan -Start (Get-Date) -End $StartDelay.AddSeconds(60)
    if ($RemainingDelay.Seconds -gt 0) {
        Write-Host "`nWaiting for application configuration and credentials to propogate..."
        Start-Sleep -Seconds $RemainingDelay.Seconds
    }

    ## Perform Tests
    Describe 'Invoke-RestMethodWithBearerAuth' {

        Context 'Public Client' {
            Write-Host
            It 'Inline as Positional Parameter' {
                $Output = Invoke-RestMethodWithBearerAuth -ClientApplication @{ ClientId = $appPublicClient.appId; TenantId = $appConfidentialClient.publisherDomain } -Scopes 'https://graph.microsoft.com/User.Read' -Uri 'https://graph.microsoft.com/oidc/userinfo'
                $Output | Should -BeOfType [PSCustomObject]
            }

            It 'Inline with NewTokenCache as Positional Parameter' {
                $Output = Invoke-RestMethodWithBearerAuth -ClientApplication @{ ClientId = $appPublicClient.appId; TenantId = $appConfidentialClient.publisherDomain } -Scopes 'https://graph.microsoft.com/User.Read' -NewTokenCache -Uri 'https://graph.microsoft.com/oidc/userinfo'
                $Output | Should -BeOfType [PSCustomObject]
            }

            Context 'Public Client from ClientApplication' {
                $ClientApplication = New-MsalClientApplication $appPublicClient.appId -TenantId $appPublicClient.publisherDomain

                It 'ClientApplication as Positional Parameter' {
                    $Output = Invoke-RestMethodWithBearerAuth -ClientApplication $ClientApplication -Scopes 'https://graph.microsoft.com/User.Read' -Uri 'https://graph.microsoft.com/oidc/userinfo'
                    $Output | Should -BeOfType [PSCustomObject]
                }
            }
        }

        Context 'Confidential Client' {
            Write-Host
            It 'Inline ClientSecret as Positional Parameter' {
                $Output = Invoke-RestMethodWithBearerAuth -ClientApplication @{ ClientId = $appConfidentialClient.appId; TenantId = $appConfidentialClient.publisherDomain; ClientSecret = ConvertFrom-SecureStringAsPlainText $ClientSecret -Force } -Uri 'https://graph.microsoft.com/v1.0/domains'
                $Output | Should -BeOfType [PSCustomObject]
            }

            It 'Inline ClientSecret with NewTokenCache as Positional Parameter' {
                $Output = Invoke-RestMethodWithBearerAuth -ClientApplication @{ ClientId = $appConfidentialClient.appId; TenantId = $appConfidentialClient.publisherDomain; ClientSecret = ConvertFrom-SecureStringAsPlainText $ClientSecret -Force } -NewTokenCache -Uri 'https://graph.microsoft.com/v1.0/domains'
                $Output | Should -BeOfType [PSCustomObject]
            }

            Context 'Confidential Client from ClientApplication' {
                $ClientApplication = New-MsalClientApplication $appConfidentialClient.appId -TenantId $appConfidentialClient.publisherDomain -ClientSecret $ClientSecret

                It 'ClientApplication with ClientSecret as Positional Parameter' {
                    $Output = Invoke-RestMethodWithBearerAuth -ClientApplication $ClientApplication -Uri 'https://graph.microsoft.com/v1.0/domains'
                    $Output | Should -BeOfType [PSCustomObject]
                }
            }
        }
    }
}
finally {
    ## Remove client credentials
    #Write-Host 'Removing client credentials...'
    $ClientCertificate | Remove-Item -Force
    #$appConfidentialClient | Remove-AzureAdClientSecret -KeyId $appConfidentialClientSecret.keyId -MSGraphToken $MSGraphToken
    #$appConfidentialClient | Remove-AzureAdClientCertificate -KeyId $appConfidentialClientCertificate.keyId -MSGraphToken $MSGraphToken

    ## Remove test client applications
    $MSGraphToken = Get-MSGraphToken @AppConfigAutomation
    $appPublicClient,$appConfidentialClient | Remove-TestAzureAdApplication -Permanently -MSGraphToken $MSGraphToken
}
