function ConvertFrom-QueryString ([string]$QueryString) {
    [psobject] $Parameters = New-Object psobject
    if ($QueryString[0] -eq '?') { $QueryString = $QueryString.Substring(1) }
    [string[]] $QueryParameters = $QueryString.Split('&')
    foreach ($QueryParameter in $QueryParameters) {
        [string[]] $QueryParameterPair = $QueryParameter.Split('=')
        $Parameters | Add-Member $QueryParameterPair[0] -MemberType NoteProperty -Value ([System.Net.WebUtility]::UrlDecode($QueryParameterPair[1]))
    }
    return $Parameters
}
