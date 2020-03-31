﻿#
# Module manifest for module 'MSIdentityTools'
#
# Generated by: Jason Thompson
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'MSIdentityTools.psm1'

# Version number of this module.
ModuleVersion = '1.0.1.1'

# Supported PSEditions
CompatiblePSEditions = 'Core','Desktop'

# ID used to uniquely identify this module
GUID = '69790621-e75d-4303-b06e-02704b7ca42f'

# Author of this module
Author = 'Jason Thompson'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2020 Jason Thompson. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Tools for working with Microsoft Identity products.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = '4.5'

# Minimum version of the common language runtime (CLR) required by this module
#CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
#ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{ ModuleName='MSAL.PS'; Guid='c765c957-c730-4520-9c36-6a522e35d60b'; ModuleVersion='4.10.0.1' }
)

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    '.\Add-AzureAdClientCertificate.ps1'
    '.\Add-AzureAdClientSecret.ps1'
    '.\Confirm-JsonWebSignature.ps1'
    '.\Confirm-JsonWebTokenSignature.ps1'
    '.\Connect-AzureAdModule.ps1'
    '.\Connect-AzureAdWithCustomApp.ps1'
    '.\ConvertFrom-AadcAadConnectorSpaceDn.ps1'
    '.\ConvertFrom-AadcSourceAnchor.ps1'
    '.\ConvertFrom-Base64String.ps1'
    '.\ConvertFrom-HexString.ps1'
    '.\ConvertFrom-JsonWebSignature.ps1'
    '.\ConvertFrom-SecureStringAsPlainText.ps1'
    '.\ConvertTo-Base64String.ps1'
    '.\ConvertTo-PsParameterString.ps1'
    '.\ConvertTo-PsString.ps1'
    '.\ConvertTo-QueryString.ps1'
    '.\Expand-JsonWebTokenPayload.ps1'
    '.\Get-AzureIpRange.ps1'
    '.\Get-MsftFederationProvider.ps1'
    '.\Get-MsftIdentityAssociation.ps1'
    '.\Get-MsftIdpAuthority.ps1'
    '.\Get-MsftTenantDiscoveryInstance.ps1'
    '.\Get-MsftUserIdPs.ps1'
    '.\Get-MsftUserRealm.ps1'
    '.\Get-O365Endpoints.ps1'
    '.\Get-OpenIdProviderConfiguration.ps1'
    '.\Get-SamlFederationMetadata.ps1'
    '.\Install-AzureAdModule.ps1'
    '.\Invoke-CommandAsSystem.ps1'
    '.\Invoke-RestMethodWithBearerAuth.ps1'
    '.\New-AzureAdClientCertificate.ps1'
    '.\New-AzureAdClientSecret.ps1'
    '.\New-AzureAdPowerShellClient.ps1'
    '.\New-AzureAdUserPassword.ps1'
    '.\Resolve-AzureIpAddress.ps1'
    '.\Resolve-MsalClientApplication.ps1'
    '.\Show-JsonWebToken.ps1'
    '.\Test-AzureAdDeviceRegConnectivity.ps1'
    '.\Test-IpAddressInSubnet.ps1'
    '.\Write-HostPrompt.ps1'
)

# Functions to export from this module
FunctionsToExport = @(
    'Add-AzureAdClientCertificate'
    'Add-AzureAdClientSecret'
    'Confirm-JsonWebSignature'
    'Confirm-JsonWebTokenSignature'
    #'Connect-AzureAdModule'
    'Connect-AzureAdWithCustomApp'
    'ConvertFrom-AadcAadConnectorSpaceDn'
    'ConvertFrom-AadcSourceAnchor'
    'ConvertFrom-JsonWebSignature'
    'Expand-JsonWebTokenPayload'
    'Get-AzureIpRange'
    #'Get-MsftFederationProvider'
    'Get-MsftIdentityAssociation'
    'Get-MsftIdpAuthority'
    'Get-MsftTenantDiscoveryInstance'
    #'Get-MsftUserIdPs'
    'Get-MsftUserRealm'
    'Get-O365Endpoints'
    'Get-OpenIdProviderConfiguration'
    'Get-SamlFederationMetadata'
    'Install-AzureAdModule'
    'Invoke-RestMethodWithBearerAuth'
    'New-AzureAdClientCertificate'
    'New-AzureAdClientSecret'
    'New-AzureAdPowerShellClient'
    'New-AzureAdUserPassword'
    'Resolve-AzureIpAddress'
    #'Resolve-MsalClientApplication'
    'Show-JsonWebToken'
    'Test-AzureAdDeviceRegConnectivity'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @(
    'Confirm-Jws'
    'Confirm-JwtSignature'
    'ConvertFrom-Jws'
    'ConvertFrom-JsonWebToken'
    'ConvertFrom-Jwt'
    'ConvertFrom-AzureAdImmutableId'
    'Expand-JwtPayload'
    'Get-WsFedFederationMetadata'
    'Show-Jwt'
)

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
#FileList = @(
#    '..\build\packages\Microsoft.Identity.Client.4.1.0\lib\netcoreapp2.1\Microsoft.Identity.Client.dll'
#    '..\build\packages\Microsoft.Identity.Client.4.1.0\lib\net45\Microsoft.Identity.Client.dll'
#)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Microsoft', 'Identity', 'Azure', 'AzureActiveDirectory', 'AzureAD', 'AAD', 'ActiveDirectory', 'AD', 'AzureADConnect', 'AADC', 'OAuth', 'OpenIdConnect', 'OIDC','JsonWebSignature','JWS','JsonWebToken','JWT'

        # A URL to the license for this module.
        LicenseUri = 'https://raw.githubusercontent.com/jasoth/MSIdentityTools/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/jasoth/MSIdentityTools'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}
