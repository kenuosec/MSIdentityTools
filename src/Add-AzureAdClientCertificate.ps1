<#
.SYNOPSIS
    Add a newly generated client certificate to a confidential client in Azure AD.
.EXAMPLE
    PS C:\>Get-AzureADApplication -Filter "AppId eq '00000000-0000-0000-0000-000000000000'" | Add-AzureAdClientCertificate
    Get an Azure AD application registration using Azure AD module, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>Get-AzureADServicePrincipal -Filter "AppId eq '00000000-0000-0000-0000-000000000000'" | Add-AzureAdClientCertificate
    Get an Azure AD service principal using Azure AD module, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>New-AzureAdConfidentialClient | Add-AzureAdClientCertificate
    Creates new Azure AD application registration, generates a non-exportable client certificate valid for 1 year, and adds it to the Azure AD object.
.EXAMPLE
    PS C:\>Add-AzureAdClientCertificate -ObjectId '00000000-0000-0000-0000-000000000000' -MakePrivateKeyExportable -Lifetime (New-TimeSpan -End (Get-Date).AddYears(3))
    Generates an exportable client certificate valid for 3 years and adds it to the Azure AD object.
.INPUTS
    System.String
#>
function Add-AzureAdClientCertificate {
    [CmdletBinding()]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param(
        # Specifies the object id of the application or service principal.
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ObjectId,
        # Allows certificate private key to be exported from local machine.
        [Parameter(Mandatory=$false)]
        [switch] $MakePrivateKeyExportable,
        # Valid lifetime of client certificate.
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
        $PSModule = Install-AzureAdModule -ErrorAction Stop
        Import-Module -ModuleInfo $PSModule -ErrorAction Stop
        $AzureADSessionInfo = Connect-AzureAdModule -TenantId $TenantId -AccountId $AccountId -ErrorAction Stop

        $InvokeCommandMessage = "`r`n{0}`r`n`r`nDo you want to invoke the above command(s)?"
        [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
        )
    }

    process
    {
        ## Lookup Azure AD Object
        $AzureADObject = Get-AzureADObjectByObjectId -ObjectId $ObjectId -ErrorAction Stop

        if ($PSEdition -eq 'Desktop') {
            ## Generate Certificate
            [hashtable] $paramAzureAdClientCertificate = @{}
            if ($MakePrivateKeyExportable) { $paramAzureAdClientCertificate['MakePrivateKeyExportable'] = $MakePrivateKeyExportable }
            if ($Lifetime) { $paramAzureAdClientCertificate['Lifetime'] = $Lifetime }
            [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate = New-AzureAdClientCertificate $AzureADObject.DisplayName @paramAzureAdClientCertificate
        }
        else {
            ## Prompt for Certificate Path
            $InputParameters = Write-HostPrompt "Input" "Supply values for the following parameters:" -Fields @(
                New-Object System.Management.Automation.Host.FieldDescription -ArgumentList "CertificatePath"
            )
            if (!$InputParameters['CertificatePath']) {
                $Exception = New-Object System.Management.Automation.PSArgumentException -ArgumentList 'CertificatePath must not be empty or null.'
                Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::InvalidArgument) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'AddAzureAdClientCertificateFailureInvalidArgument' -TargetObject $InputParameters['CertificatePath'] -ErrorAction Stop
            }
            [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $InputParameters['CertificatePath']
        }
        Write-Output $ClientCertificate

        ## Add Certificate
        $paramKeyCredential = [ordered]@{
            Type = 'AsymmetricX509Cert'
            Usage = 'Verify'
            Value = (ConvertTo-Base64String $ClientCertificate.GetRawCertData())
            StartDate = $ClientCertificate.NotBefore
            EndDate = $ClientCertificate.NotAfter
        }
        switch ($AzureADObject.ObjectType) {
            'Application' {
                $Message = $InvokeCommandMessage -f "New-AzureADApplicationKeyCredential -ObjectId $($AzureADObject.ObjectId) $(ConvertTo-PsParameterString $paramKeyCredential -Compact)"
                $Result = Write-HostPrompt 'Add Client Certificate to Application in Azure AD:' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    New-AzureADApplicationKeyCredential -ObjectId $AzureADObject.ObjectId -ErrorAction Stop @paramKeyCredential | Out-Null
                    #Set-AzureADApplication -ObjectId $AzureADObject.ObjectId -PublicClient $false | Out-Null
                }
                else {
                    $Exception = New-Object OperationCanceledException -ArgumentList 'Adding Client Certificate to Application in Azure AD declined by user.'
                    Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'AddAzureAdClientCertificateUserDeclined'
                }
            }
            'ServicePrincipal' {
                $Message = $InvokeCommandMessage -f "New-AzureADServicePrincipalKeyCredential -ObjectId $($AzureADObject.ObjectId) $(ConvertTo-PsParameterString $paramKeyCredential -Compact)"
                $Result = Write-HostPrompt 'Add Client Certificate to Service Principal in Azure AD:' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    New-AzureADServicePrincipalKeyCredential -ObjectId $AzureADObject.ObjectId @paramKeyCredential | Out-Null
                }
                else {
                    $Exception = New-Object OperationCanceledException -ArgumentList 'Adding Client Certificate to Service Principal in Azure AD declined by user.'
                    Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'AddAzureAdClientCertificateUserDeclined'
                }
            }
        }
    }

    end {
        #Disconnect-AzureAD -Confirm:$false
    }
}
