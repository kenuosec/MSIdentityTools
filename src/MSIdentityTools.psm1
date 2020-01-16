## Set Strict Mode for Module. https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode
Set-StrictMode -Version 3.0

## PowerShell Desktop 5.1 does not dot-source ScriptsToProcess when a specific version is specified on import. This is a bug.
# if ($PSEdition -eq 'Desktop') {
#     $ModuleManifest = Import-PowershellDataFile (Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name.Replace('.psm1','.psd1'))
#     if ($ModuleManifest.ContainsKey('ScriptsToProcess')) {
#         foreach ($Path in $ModuleManifest.ScriptsToProcess) {
#             . (Join-Path $PSScriptRoot $Path)
#         }
#     }
# }

[scriptblock] $MsalAuthentication = {
    param(
        [parameter(Mandatory=$true)]
        [object] $ClientApplication,

        [Parameter(Mandatory=$false)]
        [string[]] $Scopes
    )

    ## Cmdlet Extention
    if ($ClientApplication -is [Microsoft.Identity.Client.IClientApplicationBase])
    {
        [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = $ClientApplication
    }
    elseif ($ClientApplication -is [Microsoft.Identity.Client.ApplicationOptions])
    {
        [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = $ClientApplication | Get-MsalClientApplication -CreateIfMissing
    }
    elseif ($ClientApplication -is [string])
    {
        [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = Get-MsalClientApplication -ClientId $ClientApplication -CreateIfMissing
    }

    ## Get Token
    if ($PSBoundParameters.ContainsKey('Scopes'))
    {
        [Microsoft.Identity.Client.AuthenticationResult] $MsalToken = $MsalClientApplication | Get-MsalToken -Scopes $PSBoundParameters['Scopes']
    }
    else {
        [Microsoft.Identity.Client.AuthenticationResult] $MsalToken = $MsalClientApplication | Get-MsalToken
    }

    return $MsalToken
}
