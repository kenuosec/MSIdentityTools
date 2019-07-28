<#
.SYNOPSIS
    Convert Azure AD Connect metaverse object sourceAnchor or Azure AD ImmutableId to sourceGuid.
.EXAMPLE
    PS C:\>ConvertFrom-AadcAadConnectorSpaceDN 'AAAAAAAAAAAAAAAAAAAAAA=='
    Convert Azure AD Connect metaverse object sourceAnchor to sourceGuid.
.INPUTS
    System.String
#>
function ConvertFrom-AadcSourceAnchor {
    [CmdletBinding()]
    [Alias('ConvertFrom-AzureAdImmutableId')]
    [OutputType([guid],[string])]
    param (
        # Azure AD Connect metaverse object sourceAnchor.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string] $InputObject
    )

    [guid] $SourceGuid = ConvertFrom-Base64String $InputObject -RawBytes
    return $SourceGuid
}
