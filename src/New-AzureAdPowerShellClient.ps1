<#
.SYNOPSIS
    Create a application registration in Azure AD.
.DESCRIPTION
    This application created can be used as a public client for user delegated rights or with a client secret or certificate as a confidential client.
.EXAMPLE
    PS C:\>New-AzureAdPowerShellClient
    Creates new public client application registration.
.EXAMPLE
    PS C:\>New-AzureAdPowerShellClient -TenantId 00000000-0000-0000-0000-000000000000
    Creates new public client application registration in the specified tenant.
.INPUTS
    System.String
.OUTPUTS
    Microsoft.Open.AzureAD.Model.Application
#>
function New-AzureAdPowerShellClient {
    [CmdletBinding()]
    param(
        # Specifies the display name of the application.
        [Parameter(Mandatory=$false, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $DisplayName = 'PowerShell Client',
        # Specifies the URLs that user tokens are sent to for sign in, or the redirect URIs that OAuth 2.0 authorization codes and access tokens are sent to.
        [Parameter(Mandatory=$false)]
        [string[]] $ReplyUrls = @(
            "urn:ietf:wg:oauth:2.0:oob"
            "https://login.microsoftonline.com/common/oauth2/nativeclient"
            "http://localhost/"
        ),
        # Do not create a corresponding service principal.
        [Parameter(Mandatory=$false)]
        [switch] $NoServicePrincipal,
        # Specifies the ID of a tenant.
        [Parameter(Mandatory=$false)]
        [string] $TenantId,
        # Specifies the UPN of a user.
        [Parameter(Mandatory=$false)]
        [string] $AccountId
    )

    begin
    {
        $PSModule = Install-AzureAdModule -ErrorAction Stop
        Import-Module -ModuleInfo $PSModule -ErrorAction Stop
        $AzureADSessionInfo = Connect-AzureAdModule -TenantId $TenantId -AccountId $AccountId -ErrorAction Stop
        $spMSGraph = Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft Graph'" #-Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
        $CurrentUser = Get-AzureADUser -Filter ("UserPrincipalName eq '{0}'" -f $AzureADSessionInfo.Account.Id)

        $InvokeCommandMessage = "`r`n{0}`r`n`r`nDo you want to invoke the above command(s)?"
        [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
        )
    }

    process
    {
        $paramAzureADApplication = [ordered]@{
            DisplayName = '{0} ({1})' -f $DisplayName,$AzureADSessionInfo.Account.Id
            AvailableToOtherTenants = $false
            Oauth2AllowImplicitFlow = $false
            PublicClient = $true
            ReplyUrls = $ReplyUrls
            RequiredResourceAccess = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess[]]@(
                @{
                    resourceAppId = $spMSGraph.AppId
                    resourceAccess = [Microsoft.Open.AzureAD.Model.ResourceAccess[]]@(
                        $spMSGraph.Oauth2Permissions | Where-Object Value -In 'openid','profile','email','offline_access','User.Read' | ForEach-Object {
                            @{
                                Id = $_.Id
                                Type = "Scope"
                            }
                        }
                        # @{
                        #     id = $spMSGraph.Oauth2Permissions | Where-Object Value -eq 'User.Read' | Select-Object -ExpandProperty Id  ## "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
                        #     type = "Scope"
                        # }
                    )
                }
            )
        }

        $Message = $InvokeCommandMessage -f @"
`$AzureADApplication = New-AzureADApplication $(ConvertTo-PsParameterString $paramAzureADApplication -Compact)

`$AzureADApplication | Add-AzureADApplicationOwner -RefObjectId $($CurrentUser.ObjectId)
"@
        $Result = Write-HostPrompt 'Create New Application in Azure AD:' $Message -Choices $ConfirmChoices -DefaultChoice 0
        if ($Result -eq 0) {
            ## Create Application
            Write-Verbose ('Creating new Azure AD Application [{0}].' -f $paramAzureADApplication.DisplayName)
            $AzureADApplication = New-AzureADApplication -ErrorAction Stop @paramAzureADApplication
            Write-Output $AzureADApplication

            ## Add Application Owner
            Write-Verbose ('Adding Current User [{0}] as Owner of Application [{1}].' -f $CurrentUser.UserPrincipalName, $AzureADApplication.DisplayName)
            $AzureADApplication | Add-AzureADApplicationOwner -RefObjectId $CurrentUser.ObjectId

            ## Add Application Logo
            if ($DisplayName -eq 'PowerShell Client') {
                Write-Verbose ('Adding Logo to Application [{0}].' -f $AzureADApplication.DisplayName)
                $PowerShellGalleryLogo = Invoke-WebRequest -Uri 'http://www.powershellgallery.com/favicon.ico'
                #Set-AzureADApplicationLogo -ObjectId $AzureADApplication.ObjectId -ImageByteArray $PowerShellGalleryLogoPath.Content  ## bug?
                $AzureADApplication | Set-AzureADApplicationLogo -FileStream $PowerShellGalleryLogo.RawContentStream
            }

            if (!$NoServicePrincipal) {
                $Message = $InvokeCommandMessage -f @"
`$AzureADServicePrincipal = New-AzureADServicePrincipal -AppId $($AzureADApplication.AppId) -Tags 'WindowsAzureActiveDirectoryIntegratedApp'

`$AzureADServicePrincipal | Add-AzureADServicePrincipalOwner -RefObjectId $($CurrentUser.ObjectId)
"@
                $Result = Write-HostPrompt 'Create New Service Principal in Azure AD:' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    ## Create Service Principal
                    Write-Verbose ('Creating new Azure AD Service Principal from Application [{0}].' -f $AzureADApplication.DisplayName)
                    $AzureADServicePrincipal = New-AzureADServicePrincipal -AppId $AzureADApplication.AppId -Tags 'WindowsAzureActiveDirectoryIntegratedApp'

                    ## Add Service Principal Owner
                    Write-Verbose ('Adding Current User [{0}] as Owner of Service Principal [{1}].' -f $CurrentUser.UserPrincipalName, $AzureADServicePrincipal.DisplayName)
                    $AzureADServicePrincipal | Add-AzureADServicePrincipalOwner -RefObjectId $CurrentUser.ObjectId
                }
                else {
                    $Exception = New-Object OperationCanceledException -ArgumentList 'Creation of new service principal in Azure AD declined by user.'
                    Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'NewAzureAdPowerShellClientUserDeclined'
                }
            }
        }
        else {
            $Exception = New-Object OperationCanceledException -ArgumentList 'Creation of new application in Azure AD declined by user.'
            Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'NewAzureAdPowerShellClientUserDeclined'
        }
    }

    end {
        #Disconnect-AzureAD -Confirm:$false
    }
}
