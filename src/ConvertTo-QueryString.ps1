function ConvertTo-QueryString ([hashtable]$Parameters) {
    $Query = New-Object System.Text.StringBuilder
    foreach ($Key in $Parameters.Keys) {
        if ($Query.Length -gt 0) { [void]$Query.Append('&') }
        [void]$Query.AppendFormat('{0}={1}',$Key,[System.Net.WebUtility]::UrlEncode($Parameters[$Key]))
    }
    return $Query.ToString()
}
