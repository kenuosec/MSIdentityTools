<#
.SYNOPSIS
    Add a newly generated client secret to a confidential client in Azure AD.
.EXAMPLE
    PS C:\>Get-AzureADApplication -Filter "AppId eq '00000000-0000-0000-0000-000000000000'" | Add-AzureAdClientSecret
    Get an Azure AD application registration using Azure AD module, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>Get-AzureADServicePrincipal -Filter "AppId eq '00000000-0000-0000-0000-000000000000'" | Add-AzureAdClientSecret
    Get an Azure AD service principal using Azure AD module, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>New-AzureAdConfidentialClient | Add-AzureAdClientSecret
    Creates new Azure AD application registration, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>Add-AzureAdClientSecret -ObjectId '00000000-0000-0000-0000-000000000000' -Lifetime (New-TimeSpan -End (Get-Date).AddYears(3))
    Generates a client secret valid for 3 years and adds it to the Azure AD object.
.INPUTS
    System.String
#>
function Add-AzureAdClientSecret {
    [CmdletBinding()]
    [OutputType([securestring])]
    param(
        # Specifies the object id of the application or service principal.
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ObjectId,
        # Specifies the number of random characters or bytes to generate.
        [Parameter(Mandatory=$false)]
        [int] $Length = 64,
        # Valid lifetime of client secret.
        [Parameter(Mandatory=$false)]
        [timespan] $Lifetime,
        # Specifies the ID of a tenant.
        [Parameter(Mandatory=$false)]
        [string] $TenantId,
        # Specifies the UPN of a user.
        [Parameter(Mandatory=$false)]
        [string] $AccountId
    )

    begin
    {
        $AzureADSessionInfo = Initialize-AzureAdModule -TenantId $TenantId -AccountId $AccountId -ErrorAction Stop

        $InvokeCommandMessage = @'

{0}

Do you want to invoke the above command(s)?
'@

        [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
        )

        ## Initialize
        [datetime] $StartTime = Get-Date
        if (!$Lifetime) { $Lifetime = New-TimeSpan -End $StartTime.AddYears(1) }
        [datetime] $EndTime = $StartTime.Add($Lifetime)
    }

    process
    {
        ## Lookup Azure AD Object
        $AzureADObject = Get-AzureADObjectByObjectId -ObjectId $ObjectId -ErrorAction Stop

        ## Generate Secret
        [securestring] $ClientSecret = New-AzureAdClientSecret -Length $Length
        Write-Output $ClientSecret

        ## Add Secret
        $paramPasswordCredential = [ordered]@{
            CustomKeyIdentifier = ('Generated on {0:ddd} {0:MMM} {0:dd} {0:yyyy}' -f (Get-Date))
            Value = (ConvertFrom-SecureStringAsPlainText $ClientSecret -Force)
            StartDate = $StartTime
            EndDate = $EndTime
        }
        switch ($AzureADObject.ObjectType) {
            'Application' {
                $Message = $InvokeCommandMessage -f ("New-AzureADApplicationPasswordCredential -ObjectId $($AzureADObject.ObjectId) $(ConvertTo-PsParameterString $paramPasswordCredential -Compact)" -replace ([regex]::Escape($paramPasswordCredential.Value)),'*****')
                $Result = Write-HostPrompt 'Confirm:' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    New-AzureADApplicationPasswordCredential -ObjectId $AzureADObject.ObjectId @paramPasswordCredential | Out-Null
                }
            }
            'ServicePrincipal' {
                $Message = $InvokeCommandMessage -f ("New-AzureADServicePrincipalPasswordCredential -ObjectId $($AzureADObject.ObjectId) $(ConvertTo-PsParameterString $paramPasswordCredential -Compact)" -replace ([regex]::Escape($paramPasswordCredential.Value)),'*****')
                $Result = Write-HostPrompt 'Confirm:' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    New-AzureADServicePrincipalPasswordCredential -ObjectId $AzureADObject.ObjectId @paramPasswordCredential | Out-Null
                }
            }
        }
    }

    end {
        #Disconnect-AzureAD -Confirm:$false
    }
}
