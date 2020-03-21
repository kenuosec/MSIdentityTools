<#
.SYNOPSIS
    Connect AzureAD module to an Azure AD tenant.
.EXAMPLE
    PS C:\>Connect-AzureAdModule
    Connect AzureAD module to an Azure AD tenant.
.INPUTS
    System.String
#>
function Connect-AzureAdModule {
    [CmdletBinding()]
    #[OutputType([Microsoft.Open.Azure.AD.CommonLibrary.PSAzureContext])]
    param(
        # Specifies the ID of a tenant.
        [Parameter(Mandatory=$false)]
        [string] $TenantId,
        # Specifies the UPN of a user.
        [Parameter(Mandatory=$false)]
        [string] $AccountId
    )

    $InvokeCommandMessage = "`r`n{0}`r`n`r`nDo you want to invoke the above command(s)?"
    [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
    )

    [Microsoft.Open.Azure.AD.CommonLibrary.PSAzureContext] $AzureADCurrentSessionInfo = $null
    try { $AzureADCurrentSessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue }
    catch {}
    if (!$AzureADCurrentSessionInfo) {
        $paramConnectAzureAD = [ordered]@{}
        if ($TenantId) { $paramConnectAzureAD['TenantId'] = $TenantId }
        if ($AccountId) { $paramConnectAzureAD['AccountId'] = $AccountId }

        $Message = $InvokeCommandMessage -f "Connect-AzureAD $(ConvertTo-PsParameterString $paramConnectAzureAD -Compact)"
        $Result = Write-HostPrompt 'Connect to Azure AD Tenant:' $Message -Choices $ConfirmChoices -DefaultChoice 0
        if ($Result -eq 0) {
            Connect-AzureAD -ErrorAction Stop @paramConnectAzureAD
        }
        else {
            $Exception = New-Object OperationCanceledException -ArgumentList 'Connection to Azure AD tenant declined by user.'
            Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'InitializeAzureAdModuleUserDeclined'
        }
    }
    else {
        return $AzureADCurrentSessionInfo
    }
}
