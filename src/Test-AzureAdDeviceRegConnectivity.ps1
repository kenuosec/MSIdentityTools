<#
.SYNOPSIS
    Test connectivity for Azure AD Device Registration
.EXAMPLE
    PS C:\>Test-AzureAdDeviceRegConnectivity
    Test required hostnames
.EXAMPLE
    PS C:\>Test-AzureAdDeviceRegConnectivity -AdfsHostname 'adfs.contoso.com'
    Test required hostnames and ADFS server
.INPUTS
    System.String
#>
function Test-AzureAdDeviceRegConnectivity {
    [CmdletBinding()]
    param (
        # ADFS Server
        [Parameter(Mandatory=$false)]
        [string] $AdfsHostname
    )

    Invoke-CommandAsSystem {
        param ([string]$AdfsHostname)
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

        [System.Collections.Generic.List[string]] $listHostname = @(
            'login.microsoftonline.com'
            'device.login.microsoftonline.com'
            'enterpriseregistration.windows.net'
            'autologon.microsoftazuread-sso.com'
        )
        if ($AdfsHostname) { $listHostname.Add($AdfsHostname) }

        $listHostname | Test-NetConnection -Port 443 | Format-Table ComputerName,RemotePort,RemoteAddress,TcpTestSucceeded
    } -ArgumentList $AdfsHostname
}
