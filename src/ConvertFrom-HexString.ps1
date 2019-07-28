<#
.SYNOPSIS
   Convert from Hex String
.DESCRIPTION

.EXAMPLE

.INPUTS

.NOTES

#>
function ConvertFrom-HexString {
    [CmdletBinding()]
    param (
        # Value to convert
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $InputObject,
        # Delimiter between Hex pairs
        [Parameter (Mandatory=$false)]
        [string] $Delimiter = " ",
        # Output raw byte array
        [Parameter (Mandatory=$false)]
        [switch] $RawBytes,
        # Encoding to use for text strings
        [Parameter (Mandatory=$false)]
        [ValidateSet("Ascii", "UTF32", "UTF7", "UTF8", "BigEndianUnicode", "Unicode")]
        [string] $Encoding = "Default"
    )

    process
    {
        $listBytes = New-Object object[] $InputObject.Count
        for ($iString = 0; $iString -lt $InputObject.Count; $iString++) {
            [string] $strHex = $InputObject[$iString]
            if ($strHex.Substring(2,1) -eq $Delimiter) {
                [string[]] $listHex = $strHex -split $Delimiter
            }
            else {
                [string[]] $listHex = New-Object string[] ($strHex.Length/2)
                for ($iByte = 0; $iByte -lt $strHex.Length; $iByte += 2) {
                    $listHex[[System.Math]::Truncate($iByte/2)] = $strHex.Substring($iByte, 2)
                }
            }

            [byte[]] $outBytes = New-Object byte[] $listHex.Count
            for ($iByte = 0; $iByte -lt $listHex.Count; $iByte++)
            {
                $outBytes[$iByte] = [byte]::Parse($listHex[$iByte],[System.Globalization.NumberStyles]::HexNumber)
            }

            if ($RawBytes) { $listBytes[$iString] = $outBytes }
            else {
                $outString = ([Text.Encoding]::$Encoding.GetString($outBytes))
                Write-Output $outString
            }
        }
        if ($RawBytes) {
            return $listBytes
        }
    }
}
