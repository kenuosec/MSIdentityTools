<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE
    PS C:\>
#>
function New-AzureAdClientSecret ([int]$Length=32) {
    [char[]] $Numbers = (48..57)
    [char[]] $UpperCaseLetters = (65..90)
    [char[]] $LowerCaseLetters = (97..122)
    [char[]] $Symbols = '*+-./:=?@[]_'
    [securestring] $Secret = ConvertTo-SecureString ((Get-Random -InputObject (($UpperCaseLetters+$LowerCaseLetters+$Numbers+$Symbols)*$Length) -Count $Length) -join '') -AsPlainText -Force
    return $Secret
}
