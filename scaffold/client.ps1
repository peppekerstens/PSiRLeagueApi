class League {
    # Properties
    [int]$id   #:15
    [bool]$isInitialized          #: True
    [array]$seasonIds              #: {58, 59}
    [string]$subscriptionStatus     #: Unknown
    [datetime]$createdOn              #: 13-8-2023 07:30:42
    [datetime]$lastModifiedOn         #: 17-8-2023 16:03:24
    [string]$createdByUserId        #: 64ce61ed-8f99-4fec-9d5e-e36e576bd1be
    [string]$lastModifiedByUserId   #: 64ce61ed-8f99-4fec-9d5e-e36e576bd1be
    [string]$createdByUserName      #: peppekerstens
    [string]$lastModifiedByUserName #: peppekerstens
    [string]$name                   #: pec
    [string]$nameFull               #: Platinum Endurance Championship
    [string]$description            #:
    [string]$descriptionPlain       #:
    [bool]$enableProtests         #: True
    [timespan]$protestCoolDownPeriod  #: 00:00:00.00000
    [timespan]$protestsClosedAfter    #: 01.00:00:00.00000
    [string]$protestsPublic         #: Hidden
    [string]$leaguePublic           #: PublicListed

    # Constructors
    League()
    {} 
}


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
        [ValidateSet('Get','Post','Put','Delete')]
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
    [CmdletBinding()]
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


Function LmLeague {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [league]$league
        ,
        [ValidateSet('Post','Put','Delete')]
        [string]$Method
    )

    If ($Method -eq 'Get'){$EndPoint = "Leagues"}
    
    $EndPoint = "Leagues/$($league.id)"

    $body = @{}
    if ($name){$body.nameFull = $name}
    if ($description){$body.description = $description}
    if ($descriptionPlain){$body.descriptionPlain = $descriptionPlain}
    if ($enableProtests){$body.enableProtests= $enableProtests}
    if ($protestCoolDownPeriod){$body.protestCoolDownPeriod = $protestCoolDownPeriod}
    if ($protestsClosedAfter){$body.protestsClosedAfter = $protestsClosedAfter}
    if ($protestsPublic){$body.protestsPublic = $protestsPublic}
    if ($leaguePublic){$body.leaguePublic = $leaguePublic}

    Invoke-LMRestMethod -EndPoint $EndPoint -Method $Method -body $body

}



Function Update-LmLeague {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ShortName
        ,
        [string]$Name
        ,
        [string]$description
        ,
        [string]$descriptionPlain
        ,
        [switch]$enableProtests
        ,
        [timespan]$protestCoolDownPeriod
        ,
        [timespan]$protestsClosedAfter
        ,
        [ValidatePattern("Hidden")]
        [string]$protestsPublic
        ,
        [ValidatePattern("PublicListed")]
        [string]$leaguePublic
    )

    $league = Get-LmLeague -Name $ShortName

    $EndPoint = "Leagues/$($league.id)"

    $body = @{}
    if ($name){$body.nameFull = $name}
    if ($description){$body.description = $description}
    if ($descriptionPlain){$body.descriptionPlain = $descriptionPlain}
    if ($enableProtests){$body.enableProtests= $enableProtests}
    if ($protestCoolDownPeriod){$body.protestCoolDownPeriod = $protestCoolDownPeriod}
    if ($protestsClosedAfter){$body.protestsClosedAfter = $protestsClosedAfter}
    if ($protestsPublic){$body.protestsPublic = $protestsPublic}
    if ($leaguePublic){$body.leaguePublic = $leaguePublic}

    Invoke-LMRestMethod -EndPoint $EndPoint -Method Put -body $body
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


