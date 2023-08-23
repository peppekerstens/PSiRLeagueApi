#get logged in


function Get-LmToken{
    param(
        #[pscredential]$credential
        [string]$username
        ,
        [string]$password
        ,
        [uri]$baseURI = 'https://irleaguemanager.net/api' 
        ,
        [uri]$endPoint = 'Authenticate/Login'
    )

    [uri]$uri = "$($baseURI)/$($endPoint)"

    # Create a credential object
    $cred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($username):$($password)"))

    # Headers
    $headers = @{
        "Authorization" = "Basic $cred"
        "Content-Type" = "application/json"
    }

    # Request payload
    $body = @{
        "Username" = $username
        "Password" = $password
    } | ConvertTo-Json

    # Make a POST request to the API
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
}

function Connect-LeagueManager{
    param(
        #[pscredential]$credential
        [string]$username
        ,
        [string]$password
    )
    $token = Get-LmToken -username $username -password $password
    New-Variable -Name LmSession -Value $token -Scope Global -Force
}

function Disconnect-LeagueManager{
    Remove-Variable -Name LmSession -Force
}

function Get-LmSession{
    Try{
        (Get-Variable -Name LmSession).Value
    }catch{
        throw "No LeagueManager session found! Please use Connect-LeagueManager to login"
    }
}

function Invoke-LMRestMethod {
    [CmdletBinding(SupportsShouldProcess=$True)] #adds Confirm and WhatIf options as parameter options and so forth 
    param(
        [ValidateSet('Get','Post')]
        [string]$Method = 'Get'
        ,
        [parameter(Mandatory=$true)]
        [uri]$endpoint
        ,
        [array]$body
    )

    $token = Get-LmSession

    [uri]$baseURI = 'https://irleaguemanager.net/api' 

    [uri]$uri = "$($baseURI)/$($endPoint)"

    $params = @{
        Headers = @{
            'Authorization' = "Bearer $($token)"
        }
        Method = $Method
        TimeoutSec = 60
        Verbose = $false
    }


    $QueryResult = Invoke-RestMethod @params -Uri $URI

    <#
    $QueryResults = @()
    do {
        $QueryResults += Invoke-RestMethod @params -Uri $URI
        #$QueryResults += $result.value
        $URI = $QueryResults[-1].nextlink
    } until (!($URI))

    If ($raw){
        $QueryResults
    }Else{
        $QueryResults.Value 
    }
    #>
    return $QueryResult
}

Function Get-LmLeague {
    [CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName = 'None')]
    param(
        [Parameter(ParameterSetName = 'Name')]
        [string]$Name # without this, returns all
        ,
        [Parameter(ParameterSetName = 'ShortName')]
        [string]$ShortName # without this, returns all
        ,
        [Parameter(ParameterSetName = 'Id')]
        [string]$id # without this, returns all
    )

    $EndPoint = "Leagues"
    if ($id){$EndPoint = "$($EndPoint)/$id"}
    if ($PSCmdlet.ParameterSetName -eq 'ShortName'){
        $EndPoint = $shortName
    }
    $result = Invoke-LMRestMethod -EndPoint $EndPoint
    if ($PSCmdlet.ParameterSetName -eq 'Name'){
        $result.Where{$_.nameFull -eq $Name }
    }else{
        $result
    }
}


Function New-LmLeague {
    [CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName = 'None')]
    param(
        [Parameter(ParameterSetName = 'Name')]
        [string]$Name # without this, returns all
        ,
        [Parameter(ParameterSetName = 'ShortName')]
        [string]$ShortName # without this, returns all
        ,
        [Parameter(ParameterSetName = 'Id')]
        [string]$id # without this, returns all
    )

    $EndPoint = "Leagues"
    if ($id){$EndPoint = "$($EndPoint)/$id"}
    if ($PSCmdlet.ParameterSetName -eq 'ShortName'){
        $EndPoint = $shortName
    }
    $result = Invoke-LMRestMethod -EndPoint $EndPoint
    if ($PSCmdlet.ParameterSetName -eq 'Name'){
        $result.Where{$_.nameFull -eq $Name }
    }else{
        $result
    }

    $body = @{
        "nameFull": "string",
        "description": "string",
        "descriptionPlain": "string",
        "enableProtests": true,
        "protestCoolDownPeriod": "01:02:34.56700",
        "protestsClosedAfter": "01:02:34.56700",
        "protestsPublic": "Hidden",
        "leaguePublic": "PublicListed",
        "name": "string"
      }
}

Function Get-LmChampionships {
    param(
        [parameter(Mandatory=$true)]
        [string]$leagueName #short name of league
        ,
        [string]$id # without this, returns all
    )

    $EndPoint = "$($leagueName)/Championships"
    if ($id){$EndPoint = "$($EndPoint)/$id"}
    Invoke-LMRestMethod -EndPoint $EndPoint  
}


