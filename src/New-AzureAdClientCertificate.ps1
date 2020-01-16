<#
.SYNOPSIS
    Generate Client Certificate on local machine for application registration or service principal in Azure AD.
.EXAMPLE
    PS C:\>New-AzureAdClientCertificate -ApplicationName MyApp
    Generates a new client certificate for application named "MyApp".
.EXAMPLE
    PS C:\>New-AzureAdClientCertificate -ApplicationName MyApp -MakePrivateKeyExportable -Lifetime (New-TimeSpan -End (Get-Date).AddYears(3))
    Generates a new exportable client certificate valid for 3 years.
#>
function New-AzureAdClientCertificate {
    [CmdletBinding()]
    [OutputType([securestring])]
    param (
        # Name of Application.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $ApplicationName,
        # Allows certificate private key to be exported from local machine.
        [Parameter(Mandatory=$false)]
        [switch] $MakePrivateKeyExportable,
        # Valid lifetime of client certificate.
        [Parameter(Mandatory=$false)]
        [timespan] $Lifetime
    )

    begin
    {
        ## Initialize
        [string] $KeyExportPolicy = 'NonExportable'
        if ($MakePrivateKeyExportable) { $KeyExportPolicy = 'ExportableEncrypted' }

        [datetime] $StartTime = Get-Date
        if (!$Lifetime) { $Lifetime = New-TimeSpan -End $StartTime.AddYears(1) }
        [datetime] $EndTime = $StartTime.Add($Lifetime)
    }

    process {
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate = New-SelfSignedCertificate -Subject ('CN={0}' -f $ApplicationName) -KeyFriendlyName $ApplicationName -HashAlgorithm sha256 -KeySpec Signature -KeyLength 2048 -Type Custom -NotBefore $StartTime -NotAfter $EndTime -KeyExportPolicy $KeyExportPolicy -CertStoreLocation Cert:\CurrentUser\My
        Write-Output $ClientCertificate
    }

}
