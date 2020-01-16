<#
.SYNOPSIS
    Install and connect Azure AD module.
.EXAMPLE
    PS C:\>Initialize-AzureAdModule
    Install module (if needed) and connect.
.INPUTS
    System.String
#>
function Initialize-AzureAdModule {
    [CmdletBinding()]
    param(
        # Specifies the ID of a tenant.
        [Parameter(Mandatory=$false)]
        [string] $TenantId = 'common',
        # Specifies the UPN of a user.
        [Parameter(Mandatory=$false)]
        [string] $AccountId
    )

    begin
    {
        $InvokeCommandMessage = @'

{0}

Do you want to invoke the above command(s)?
'@

        [System.Management.Automation.Host.ChoiceDescription[]] $ConfirmChoices = @(
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes", "Continue with the operation."
            New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No", "Do not proceed with the operation."
        )

        if ($PSEdition -eq 'Desktop') {
            ## Ensure Module is installed
            if (!(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
                $Message = $InvokeCommandMessage -f "Install-Module AzureAD -Confirm:`$false -Force:`$false"

                $Result = Write-HostPrompt 'This cmdlet requires another module.' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    Install-Module AzureAD -Confirm:$false -Force:$false -ErrorAction Stop
                }
                else {
                    throw 'Module installation declined.'
                }
            }
        }
        else {
            ## Ensure Preview Module is installed
            if (!(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
                $Message = $InvokeCommandMessage -f @"
`$PSRepository = Register-PSRepository PSTestGallery -SourceLocation 'https://www.poshtestgallery.com/api/v2'
Install-Module -Name AzureAD.Standard.Preview -RequiredVersion 0.0.0.10
`$PSRepository | Unregister-PSRepository
"@

                $Result = Write-HostPrompt 'This cmdlet requires another module.' $Message -Choices $ConfirmChoices -DefaultChoice 0
                if ($Result -eq 0) {
                    try {
                        $PSRepository = Register-PSRepository PSTestGallery -SourceLocation 'https://www.poshtestgallery.com/api/v2'
                        Install-Module -Name AzureAD.Standard.Preview -MaximumVersion 0.1.599.0 -Confirm:$false -Force:$false -ErrorAction Stop
                    }
                    finally {
                        $PSRepository | Unregister-PSRepository
                    }
                }
                else {
                    throw 'Module installation declined.'
                }
            }
        }

        $paramConnectAzureAD = [ordered]@{}
        if ($TenantId) { $paramConnectAzureAD['TenantId'] = $TenantId }
        if ($AccountId) { $paramConnectAzureAD['AccountId'] = $AccountId }

        $Message = $InvokeCommandMessage -f "Connect-AzureAD $(ConvertTo-PsParameterString $paramConnectAzureAD -Compact)"
        $Result = Write-HostPrompt 'Confirm:' $Message -Choices $ConfirmChoices -DefaultChoice 0
        if ($Result -eq 0) {
            Connect-AzureAD -ErrorAction Stop @paramConnectAzureAD
        }
        else {
            throw 'Azure AD connection declined.'
        }
    }
}
