
function Resolve-MsalClientApplication {
    [CmdletBinding()]
    param(
        # Client Application configuration such as ClientId.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object[]] $ClientApplications,
        # Forces a fresh authentication by creating a new TokenCache instance.
        [Parameter(Mandatory=$false)]
        [switch] $NewTokenCache
    )

    process
    {
        foreach ($ClientApplication in $ClientApplications) {
            if ($ClientApplication -is [Microsoft.Identity.Client.IClientApplicationBase])
            {
                [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = $ClientApplication
            }
            elseif ($ClientApplication -is [Microsoft.Identity.Client.ApplicationOptions] -or $ClientApplication -is [string])
            {
                if ($NewTokenCache) {
                    [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = New-MsalClientApplication $ClientApplication | Add-MsalClientApplication -PassThru
                }
                else {
                    [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = Select-MsalClientApplication $ClientApplication
                }
            }
            elseif ($ClientApplication -is [hashtable])
            {
                if ($ClientApplication.ContainsKey('ClientSecret') -or $ClientApplication.ContainsKey('ClientCertificate')) {
                    [Microsoft.Identity.Client.ConfidentialClientApplicationOptions] $ApplicationOptions = New-Object Microsoft.Identity.Client.ConfidentialClientApplicationOptions -Property $ClientApplication
                }
                else {
                    [Microsoft.Identity.Client.PublicClientApplicationOptions] $ApplicationOptions = New-Object Microsoft.Identity.Client.PublicClientApplicationOptions -Property $ClientApplication
                }
                if ($NewTokenCache) {
                    [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = New-MsalClientApplication $ApplicationOptions | Add-MsalClientApplication -PassThru
                }
                else {
                    [Microsoft.Identity.Client.IClientApplicationBase] $MsalClientApplication = Select-MsalClientApplication $ApplicationOptions
                }
            }
            else {
                # Otherwise, write a terminating error message indicating that input object type is not supported.
                $errorMessage = "Cannot parse ClientApplication type [{0}]." -f $InputObject.GetType()
                Write-Error -Message $errorMessage -Category ([System.Management.Automation.ErrorCategory]::ParserError) -ErrorId "ResolveMsalClientApplicationFailureTypeNotSupported"
            }
        }
        Write-Output $MsalClientApplication
    }
}
