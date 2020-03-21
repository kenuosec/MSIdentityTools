[CmdletBinding()]
param (
    #
    [Parameter(Mandatory=$false)]
    [string] $ModulePath = "..\src\*.psd1",
    #
    [Parameter(Mandatory=$false)]
    [string] $FunctionPath = "..\src\Resolve-MsalClientApplication.ps1"
)

Import-Module $ModulePath -Force
. $FunctionPath

## Load Test Helper Functions
. (Join-Path $PSScriptRoot 'TestCommon.ps1')

## Perform Tests
Describe 'Resolve-MsalClientApplication' {

    Context 'Public Client' {
        Write-Host
        It 'ClientId as Positional Parameter' {
            $Output = Resolve-MsalClientApplication 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }

        It 'ClientId as Pipeline Input' {
            $Output = 'da616bc2-4047-43c7-9e1d-3fda870e8e7b' | Resolve-MsalClientApplication
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }

        It 'PublicClientApplicationOptions as Positional Parameter' {
            $Input = New-Object Microsoft.Identity.Client.PublicClientApplicationOptions -Property @{ ClientId = 'da616bc2-4047-43c7-9e1d-3fda870e8e7b' }
            $Input | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplicationOptions]
            $Output = Resolve-MsalClientApplication $Input
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }

        It 'PublicClientApplicationOptions as Pipeline Input' {
            $Input = New-Object Microsoft.Identity.Client.PublicClientApplicationOptions -Property @{ ClientId = 'da616bc2-4047-43c7-9e1d-3fda870e8e7b' }
            $Input | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplicationOptions]
            $Output = $Input | Resolve-MsalClientApplication
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }

        It 'Hashtable as Positional Parameter' {
            $Input = @{ ClientId = 'da616bc2-4047-43c7-9e1d-3fda870e8e7b' }
            $Input | Should -BeOfType [Hashtable]
            $Output = Resolve-MsalClientApplication $Input
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }

        It 'Hashtable as Pipeline Input' {
            $Input = @{ ClientId = 'da616bc2-4047-43c7-9e1d-3fda870e8e7b' }
            $Input | Should -BeOfType [Hashtable]
            $Output = $Input | Resolve-MsalClientApplication
            $Output | Should -BeOfType [Microsoft.Identity.Client.PublicClientApplication]
            $Output.ClientId | Should -Be 'da616bc2-4047-43c7-9e1d-3fda870e8e7b'
        }
    }

    Context 'Confidential Client' {

        Context 'Confidential Client with ClientSecret' {
            Write-Host
            It 'ConfidentialClientApplicationOptions as Positional Parameter with ClientSecret' {
                $Input = New-Object Microsoft.Identity.Client.ConfidentialClientApplicationOptions -Property @{ ClientId = '70558b77-ccf2-4bef-9e04-e90f01c88bb1'; ClientSecret = 'SuperSecretString' }
                $Input | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplicationOptions]
                $Output = Resolve-MsalClientApplication $Input
                $Output | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplication]
                $Output.ClientId | Should -Be '70558b77-ccf2-4bef-9e04-e90f01c88bb1'
                $Output.AppConfig.ClientSecret | Should -Be 'SuperSecretString'
            }

            It 'ConfidentialClientApplicationOptions as Pipeline Input with ClientSecret' {
                $Input = New-Object Microsoft.Identity.Client.ConfidentialClientApplicationOptions -Property @{ ClientId = '70558b77-ccf2-4bef-9e04-e90f01c88bb1'; ClientSecret = 'SuperSecretString' }
                $Input | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplicationOptions]
                $Output = $Input | Resolve-MsalClientApplication
                $Output | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplication]
                $Output.ClientId | Should -Be '70558b77-ccf2-4bef-9e04-e90f01c88bb1'
                $Output.AppConfig.ClientSecret | Should -Be 'SuperSecretString'
            }

            It 'Hashtable as Positional Parameter with ClientSecret' {
                $Input = @{ ClientId = '70558b77-ccf2-4bef-9e04-e90f01c88bb1'; ClientSecret = 'SuperSecretString' }
                $Input | Should -BeOfType [Hashtable]
                $Output = Resolve-MsalClientApplication $Input
                $Output | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplication]
                $Output.ClientId | Should -Be '70558b77-ccf2-4bef-9e04-e90f01c88bb1'
                $Output.AppConfig.ClientSecret | Should -Be 'SuperSecretString'
            }

            It 'Hashtable as Pipeline Input with ClientSecret' {
                $Input = @{ ClientId = '70558b77-ccf2-4bef-9e04-e90f01c88bb1'; ClientSecret = 'SuperSecretString' }
                $Input | Should -BeOfType [Hashtable]
                $Output = $Input | Resolve-MsalClientApplication
                $Output | Should -BeOfType [Microsoft.Identity.Client.ConfidentialClientApplication]
                $Output.ClientId | Should -Be '70558b77-ccf2-4bef-9e04-e90f01c88bb1'
                $Output.AppConfig.ClientSecret | Should -Be 'SuperSecretString'
            }
        }
    }
}
