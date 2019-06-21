## Get the Auth Token

Function Get-AppDAPIToken
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory   = $False)]
        [string] $AppDServer   = "https://arb.saas.appdynamics.com",
        [Parameter(Mandatory   = $False)]
        [string] $AppDPath     = "/controller/api/oauth/access_token",
        [Parameter(Mandatory   = $False)]
        [string] $ClientSecret 
    )
    $Body               = "grant_type=client_credentials&client_id=PowerShell@arb&client_secret=$ClientSecret"
    $AppDURL            = $AppDServer + $AppDPath  
    $Token              = Invoke-RestMethod $AppDURL -Body $Body -Method Post
    $AccessToken        = $Token.access_token
    $AccessToken
}

$AccessToken = Get-AppDAPIToken -ClientSecret $ClientSecret

## Use Access Token to get the applications from App Dynamics Controller

Function Get-AppDApplications
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory   = $False)]
        [string] $AppDServer   = "https://arb.saas.appdynamics.com",
        [Parameter(Mandatory   = $False)]
        [string] $AppDPath     = "/controller/rest/applications",
        [Parameter(Mandatory   = $False)]
        [string] $APIAccessToken
    )

    $RequestHeaders     = @{
        "Accept"        = "*/*"
        "Authorization" = "Bearer " + $APIAccessToken
    }
    $AppDURL            = $AppDServer + $AppDPath  
    $Response           = Invoke-RestMethod $AppDURL -Headers $RequestHeaders -Method GET
    $Applications       = $Response.applications.application
    $Applications
}

$Applications = Get-AppDApplications -APIAccessToken $AccessToken

# Get the health rules for any particular applications

Function Get-AppDHealthRules
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory   = $False)]
        [string] $AppDServer   = "https://arb.saas.appdynamics.com",
        [Parameter(Mandatory   = $False)]
        [string] $AppDPath     = "/controller/healthrules/",
        [Parameter(Mandatory   = $False)]
        [string] $AppID,
        [Parameter(Mandatory   = $False)]
        [string] $APIAccessToken
    )

    $RequestHeaders     = @{
        "Accept"        = "*/*"
        "Authorization" = "Bearer " + $APIAccessToken
    }
    $AppDURL            = $AppDServer + $AppDPath + $AppID
    $Response           = Invoke-RestMethod $AppDURL -Headers $RequestHeaders -Method GET
    $HealthRules        = $Response.'health-rules'.'health-rule'
    $HealthRules
}


Get-AppDHealthRules -AppID 1719 -APIAccessToken $AccessToken


### Troubleshooting CURL with Fiddler:

#############################################################################################

$CurlExecutable = "C:\Windows\System32\curl.exe"
$CurlArguments = "-k", "https://arb.saas.appdynamics.com/controller/healthrules/1719",
                 "--header", "Authorization: Bearer $AccessToken",
                 "--form", "file=@$HealthRulePath",
                 "-s",
                 "-x", "127.0.0.1:8888"

#############################################################################################

# Exporting a specific health rule to file:

$uri = "https://arb.saas.appdynamics.com/controller/healthrules/1212/?name=01-BT-CheckoutFlow-2kBTs"

$RequestHeaders     = @{
    "Accept"        = "*/*"
    "Authorization" = "Bearer " + $AccessToken
}

Invoke-WebRequest -Uri $uri -Method Get -Headers $RequestHeaders -OutFile C:\temp\01-BT-CheckoutFlow-2kBTs.xml

###############################################################################################################

#############################################################################################

# Exporting ALL health rules to file, just omit the ?name=<healthrule> portion in the URL:

$uri = "https://arb.saas.appdynamics.com/controller/healthrules/1212"

$RequestHeaders     = @{
    "Accept"        = "*/*"
    "Authorization" = "Bearer " + $AccessToken
}

Invoke-WebRequest -Uri $uri -Method Get -Headers $RequestHeaders -OutFile C:\temp\prod-pws-web-HealthRules.xml

###############################################################################################################



Function Import-AppDHealthRules
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory   = $False)]
        [string] $AppDServer   = "https://arb.saas.appdynamics.com",
        [Parameter(Mandatory   = $False)]
        [string] $AppDPath     = "/controller/healthrules/",
        [Parameter(Mandatory   = $False)]
        [string] $AppID,
        [Parameter(Mandatory   = $False)]
        [string] $APIAccessToken,
        [Parameter(Mandatory   = $False)]
        [string] $HealthRulePath,
        [Parameter(Mandatory   = $False)]
        [string] $Overwrite
    )

    $AppDURL          = $AppDServer + $AppDPath + $AppID
    $CurlExecutable   = "C:\Windows\System32\curl.exe"
    $CurlArguments    = "$AppDURL",
                        "--header", "Authorization: Bearer $APIAccessToken",
                        "--form", "file=@$HealthRulePath",
                        "-s"
    & $CurlExecutable @CurlArguments
}

Import-AppDHealthRules -AppID 1719 -APIAccessToken $AccessToken -HealthRulePath "C:\temp\prod-pws-web-HealthRules.xml"





############################################################################
###  Importing the health rules using CURL 

$HealthRulePath = "C:\temp\prod-pws-web-HealthRules.xml"

$CurlExecutable = "C:\Windows\System32\curl.exe"
$CurlArguments = "https://arb.saas.appdynamics.com/controller/healthrules/1719?overwrite=true",
                 "--header", "Authorization: Bearer $AccessToken",
                 "--form", "file=@$HealthRulePath",
                 "-s"

& $CurlExecutable @CurlArguments

############################################################################