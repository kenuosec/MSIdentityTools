Set-StrictMode -Version Latest

<#
.SYNOPSIS
   Convert to Hex String
.DESCRIPTION
   
.EXAMPLE
   
.INPUTS
   
.NOTES
   
#>
function ConvertTo-HexString {
    [CmdletBinding()]
    param (
        # Value to convert
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline=$true)]
        [object] $InputObject,
        # Delimiter between Hex pairs
        [Parameter (Mandatory=$false)]
        [string] $Delimiter = " ",
        # Encoding to use for text strings
        [Parameter (Mandatory=$false)]
        [ValidateSet("Ascii", "UTF32", "UTF7", "UTF8", "BigEndianUnicode", "Unicode")]
        [string] $Encoding = "Default"       
    )

    process 
    {
        [byte[]] $inputBytes = $null
        if(($InputObject -is [Byte[]]) -or $InputObject -is [Byte])
        {
            $inputBytes = $InputObject
        }
        elseif($InputObject -is [guid])
        {
            $inputBytes = $InputObject.ToByteArray()
        }
        elseif($InputObject -is [string])
        {
            $inputBytes = [Text.Encoding]::$Encoding.GetBytes($InputObject)
        }
        elseif($InputObject -is [System.IO.FileSystemInfo])
        {
            $inputBytes = [Text.Encoding]::$Encoding.GetBytes((Get-Content $InputObject.FullName -Raw -Encoding $Encoding))
        }
        else
        {
            # Otherwise, write a non-terminating error message indicating that input object type is not supported.
            $errorMessage = "Cannot convert input of type {0} to Hex string." -f $InputObject.GetType()
            Write-Error -Message $errorMessage -Category ([System.Management.Automation.ErrorCategory]::ParserError) -ErrorId "ConvertHexFailureTypeNotSupported"
        }

        if ($inputBytes) {
            [string[]] $outHexString = New-Object string[] $inputBytes.Count
            for ($iByte = 0; $iByte -lt $inputBytes.Count; $iByte++) {
                $outHexString[$iByte] = $inputBytes[$iByte].ToString("X2")
            }
            return $outHexString -join $Delimiter
            #return [System.BitConverter]::ToString($inputBytes)
        }
    }
}
