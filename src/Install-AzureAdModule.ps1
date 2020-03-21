<#
.SYNOPSIS
    Install the appropriate Azure AD module for the PowerShell Edition (Desktop vs Core).
.EXAMPLE
    PS C:\>Install-AzureAdModule
    Install the appropriate Azure AD module for the PowerShell Edition (Desktop vs Core).
.INPUTS
    System.String
#>
function Install-AzureAdModule {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param()

    $InvokeCommandMessage = "`r`n{0}`r`n`r`nDo you want to invoke the above command(s)?"
    [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
        New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
    )

    if ($PSEdition -eq 'Desktop') {
        [System.Management.Automation.PSModuleInfo[]] $PSModule = Get-Module AzureAD,AzureADPreview -ListAvailable
        if (!$PSModule) {
            $Message = $InvokeCommandMessage -f "Install-Module AzureAD"

            $Result = Write-HostPrompt 'Install AzureAD PowerShell Module:' $Message -Choices $ConfirmChoices -DefaultChoice 0
            if ($Result -eq 0) {
                Install-Module AzureAD -Confirm:$false -Force:$false -ErrorAction Stop
                $PSModule = Get-Module AzureAD -ListAvailable
            }
            else {
                $Exception = New-Object OperationCanceledException -ArgumentList 'PowerShell module installation declined by user.'
                Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'InstallAzureAdModuleUserDeclined'
            }
        }
    }
    else {
        [System.Management.Automation.PSModuleInfo[]] $PSModule = Get-Module AzureAD.Standard.Preview -ListAvailable
        if (!$PSModule) {
            $Message = $InvokeCommandMessage -f @"
Register-PSRepository PSTestGallery -SourceLocation 'https://www.poshtestgallery.com/api/v2'
Install-Module -Name AzureAD.Standard.Preview -MaximumVersion 0.1.599.0
Unregister-PSRepository PSTestGallery
"@

            $Result = Write-HostPrompt 'Install AzureAD.Standard.Preview PowerShell Module for PowerShell Core:' $Message -Choices $ConfirmChoices -DefaultChoice 0
            if ($Result -eq 0) {
                try {
                    $PSRepository = Get-PSRepository | Where-Object SourceLocation -eq 'https://www.poshtestgallery.com/api/v2'
                    if (!$PSRepository) {
                        Register-PSRepository PSTestGallery -SourceLocation 'https://www.poshtestgallery.com/api/v2'
                    }
                    Install-Module -Name AzureAD.Standard.Preview -MaximumVersion 0.1.599.0 -Confirm:$false -Force:$false -ErrorAction Stop
                    $PSModule = Import-Module AzureAD.Standard.Preview
                }
                finally {
                    if (!$PSRepository) { Unregister-PSRepository PSTestGallery }
                }
            }
            else {
                $Exception = New-Object OperationCanceledException -ArgumentList 'PowerShell module installation declined by user.'
                Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::OperationStopped) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'InstallAzureAdModuleUserDeclined'
            }
        }
    }

    return $PSModule[0]
}
