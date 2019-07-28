Set-StrictMode -Version 2.0

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
