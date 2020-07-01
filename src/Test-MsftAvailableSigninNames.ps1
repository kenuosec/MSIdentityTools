<#
.SYNOPSIS
   Check sign-in name availablility for MSA creation
.EXAMPLE
   Test-MsftAvailableSigninNames user@domain.com
.EXAMPLE
   'user1@domainA.com','user2@domainA.com','user@domainB.com' | Test-MsftAvailableSigninNames
#>
function Test-MsftAvailableSigninNames {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        #
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [string[]] $SignInNames,
        # Suggest available names for outlook domains
        [Parameter(Mandatory = $false)]
        [switch] $IncludeSuggestions
    )

    process {
        foreach ($SignInName in $SignInNames) {
            ## Get API parameter values
            $InitSessionResponse = Invoke-WebRequest -UseBasicParsing -Method Get -Uri 'https://signup.live.com/?lic=1' -SessionVariable 'WebSession'
            #$InitSessionResponse.Headers.'Set-Cookie'

            ## Extract API parameter values from response
            if ($InitSessionResponse.Content -match 'var t0=({.*})') {
                $t0 = ConvertFrom-Json $Matches[1]
            }

            ## Invoke API for provided sign-in name
            $uriCheckAvailableSigninNames = New-Object System.UriBuilder 'https://signup.live.com/API/CheckAvailableSigninNames'
            $Result = Invoke-RestMethod -UseBasicParsing -Method Post -Uri $uriCheckAvailableSigninNames.Uri.AbsoluteUri -WebSession $WebSession -Headers @{ canary = $t0.apiCanary } -ContentType 'application/json; charset=UTF-8' -Body (ConvertTo-Json @{
                    signInName         = $SignInName
                    includeSuggestions = $IncludeSuggestions.ToBool()
                    uaid               = $t0.uaid
                    uiflvr             = $t0.uiflvr
                    scid               = $t0.scid
                    hpgid              = $t0.cpgids.Signup_MemberNamePage_Client
                })

            if ($Result.error) {
                ## Lookup errorCode
                $ErrorCodeResponse = Invoke-WebRequest -Method Get -uri 'https://acctcdn.msauth.net/lightweightsignuppackage__7LKxh3Z8DPGqZjdLup4dw2.js?v=1' -WebSession $WebSession
                if ($ErrorCodeResponse.Content -match '\$Config\.WLXAccount\.signup\.errorCodes=({.*})') {
                    $errorCodes = ConvertFrom-Json $Matches[1]
                    [hashtable] $mapErrorCodes = @{ }
                    foreach ($errorCode in ($errorCodes | Get-Member -MemberType NoteProperty)) {
                        $mapErrorCodes.Add($errorCodes.($errorCode.Name), $errorCode.Name)
                    }
                    $Result.error | Add-Member codeName -MemberType NoteProperty -Value $mapErrorCodes[$Result.error.code]
                }
            }
            Write-Output $Result
        }
    }
}
