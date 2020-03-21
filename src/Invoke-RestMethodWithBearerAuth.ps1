# .ExternalHelp MSIdentityTools-Help.xml
function Invoke-RestMethodWithBearerAuth {
    [CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=217034')]
    [Alias('Invoke-RestMethodWithMsal')]
    param(

        [Parameter(Mandatory=$true)]
        [object] $ClientApplication,

        [Parameter(Mandatory=$false)]
        [string[]] $Scopes,

        [Parameter(Mandatory=$false)]
        [switch] $NewTokenCache,

        [Microsoft.PowerShell.Commands.WebRequestMethod]
        ${Method},

        [switch]
        ${UseBasicParsing},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Uri},

        [Microsoft.PowerShell.Commands.WebRequestSession]
        ${WebSession},

        [Alias('SV')]
        [string]
        ${SessionVariable},

        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [switch]
        ${UseDefaultCredentials},

        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateThumbprint},

        [ValidateNotNull()]
        [X509Certificate]
        ${Certificate},

        [string]
        ${UserAgent},

        [switch]
        ${DisableKeepAlive},

        [ValidateRange(0, 2147483647)]
        [int]
        ${TimeoutSec},

        [System.Collections.IDictionary]
        ${Headers},

        [ValidateRange(0, 2147483647)]
        [int]
        ${MaximumRedirection},

        [uri]
        ${Proxy},

        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},

        [switch]
        ${ProxyUseDefaultCredentials},

        [Parameter(ValueFromPipeline=$true)]
        [System.Object]
        ${Body},

        [string]
        ${ContentType},

        [ValidateSet('chunked','compress','deflate','gzip','identity')]
        [string]
        ${TransferEncoding},

        [string]
        ${InFile},

        [string]
        ${OutFile},

        [switch]
        ${PassThru})

    begin
    {
        ## Cmdlet Extention
        $MsalClientApplication = Resolve-MsalClientApplication $ClientApplication -NewTokenCache:$NewTokenCache

        ## Get Token
        if ($PSBoundParameters.ContainsKey('Scopes'))
        {
            [Microsoft.Identity.Client.AuthenticationResult] $MsalToken = $MsalClientApplication | Get-MsalToken -Scopes $PSBoundParameters['Scopes']
        }
        else {
            [Microsoft.Identity.Client.AuthenticationResult] $MsalToken = $MsalClientApplication | Get-MsalToken
        }

        ## Inject bearer token
        if ($PSBoundParameters.ContainsKey('Headers')) {
            [System.Collections.IDictionary] $Headers = $PSBoundParameters['Headers']
        }
        else {
            [System.Collections.IDictionary] $Headers = @{}
            $PSBoundParameters.Add('Headers', $Headers)
        }
        if ($Headers.ContainsKey('Authorization')) {
            $Headers['Authorization'] = $MsalToken.CreateAuthorizationHeader()
        }
        else {
            $Headers.Add('Authorization', $MsalToken.CreateAuthorizationHeader())
        }

        ## Remove extra parameters
        if ($PSBoundParameters.ContainsKey('ClientApplication')) { [void] $PSBoundParameters.Remove('ClientApplication') }
        if ($PSBoundParameters.ContainsKey('Scopes')) { [void] $PSBoundParameters.Remove('Scopes') }
        if ($PSBoundParameters.ContainsKey('NewTokenCache')) { [void] $PSBoundParameters.Remove('NewTokenCache') }

        ## Resume Command
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Invoke-RestMethod', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Invoke-RestMethod
    .ForwardHelpCategory Cmdlet

    #>

}
