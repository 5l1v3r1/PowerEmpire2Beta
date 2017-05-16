<#
.Synopsis
   Get logged events for actions taken in a Empire server.
.DESCRIPTION
   Get logged events for actions taken in a Empire server.
.PARAMETER Id
    Empire session Id of the session to use.
.PARAMETER Token
    Empire API token to use to execute the action.
.PARAMETER ComputerName
    IP Address or FQDN of remote Empire server.
.PARAMETER Port
    Port number to use in the connection to the remote Empire server.
.PARAMETER NoSSLCheck
    Do not check if the TLS/SSL certificate of the Empire is valid.
.PARAMETER Type
    Type of event to retrieve. (Checkin, Task, Result, Rename)
.EXAMPLE
   C:\PS> Get-EmpireLoggedEvent -Id 0 -Type Checkin
   Get all check in events.
.NOTES
    Licensed under BSD 3-Clause license
#>
function Get-EmpireLoggedEvent {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName='Session',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Int]
        $Id,
        
        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Token,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]
        $Port = 1337,
        
        [Parameter(Mandatory=$false)]
        [switch]
        $NoSSLCheck,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Checkin', 'Task', 'Result', 'Rename')]
        [string]
        $Type
    )

    Begin {
        if ($NoSSLCheck) {
            DisableSSLCheck
        }
    }
    Process {
        
        switch ($PSCmdlet.ParameterSetName) {
            'session' { $sessionobj = Get-EmpireSession -Id $Id
                if ($sessionobj) {
                   $RequestOpts = @{}
                    $RequestOpts.Add('Method','Get')
                    if ($Type) {
                        $RequestOpts.Add('Uri', "https://$($sessionobj.host):$($sessionobj.port)/api/reporting/type/$($Type.ToLower())")
                    } else {
                        $RequestOpts.Add('Uri', "https://$($sessionobj.host):$($sessionobj.port)/api/reporting")
                    }
                    $RequestOpts.Add('ContentType', 'application/json')
                    $RequestOpts.Add('Body', @{'token'= $sessionobj.token})
                } else {
                    Write-Error -Message "Session not found."
                    return
                }
            }
            
            'Direct' {
                $RequestOpts = @{}
                $RequestOpts.Add('Method','Get')
                if ($Type) {
                    $RequestOpts.Add('Uri', "https://$($ComputerName):$($Port)/api/reporting/type/$($Type.ToLower())")
                } else {
                    $RequestOpts.Add('Uri', "https://$($ComputerName):$($Port)/api/reporting")
                }
                $RequestOpts.Add('ContentType', 'application/json')
                $RequestOpts.Add('Body', @{'token'= $token})
            }
            Default {}
        }
        
        
        $response = Invoke-RestMethod @RequestOpts
        if ($response) {
           $response.reporting | ForEach-Object -Process {
               $_.pstypenames[0] = 'Empire.Logged.Event'
               $_
           }
        } else {
            Write-Warning -Message 'No resposnse received.'
        }
    }
    End{
    }
}


<#
.Synopsis
   Get all events for a specified agent on a Empire server.
.DESCRIPTION
   Get all events for a specified agent on a Empire server.
.PARAMETER Id
    Empire session Id of the session to use.
.PARAMETER Token
    Empire API token to use to execute the action.
.PARAMETER ComputerName
    IP Address or FQDN of remote Empire server.
.PARAMETER Port
    Port number to use in the connection to the remote Empire server.
.PARAMETER NoSSLCheck
    Do not check if the TLS/SSL certificate of the Empire is valid.
.PARAMETER Name
    Agent name to retrieve events for.
.EXAMPLE
   C:\PS> Get-EmpireAgentLoggedEvent -Id 0 -Name 4SUEUTPA2YWBEZL3
   Get all event for the specified agent.
.NOTES
    Licensed under BSD 3-Clause license
#><#-<<<----------------------------------------------------- Length = 0 ?? test after action#>
function Get-EmpireAgentLoggedEvent {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName='Session',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Int]
        $Id,
        
        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Token,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]
        $Port = 1337,
        
        [Parameter(Mandatory=$false)]
        [switch]
        $NoSSLCheck,
        
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    Begin {
        if ($NoSSLCheck) {
            DisableSSLCheck
        }
    }
    Process {
        
        switch ($PSCmdlet.ParameterSetName) {
            'session' { $sessionobj = Get-EmpireSession -Id $Id
                if ($sessionobj) {
                   $RequestOpts = @{}
                    $RequestOpts.Add('Method','Get')
                    $RequestOpts.Add('Uri', "https://$($sessionobj.host):$($sessionobj.port)/api/reporting/agent/$($Name)")
                    $RequestOpts.Add('ContentType', 'application/json')
                    $RequestOpts.Add('Body', @{'token'= $sessionobj.token})
                } else {
                    Write-Error -Message "Session not found."
                    return
                }
            }
            
            'Direct' {
                $RequestOpts = @{}
                $RequestOpts.Add('Method','Get')
                $RequestOpts.Add('Uri', "https://$($ComputerName):$($Port)/api/reporting/agent/$($Name)")
                $RequestOpts.Add('ContentType', 'application/json')
                $RequestOpts.Add('Body', @{'token'= $token})
            }
            Default {}
        }
        
        
        $response = Invoke-RestMethod @RequestOpts
        if ($response) {
           $response.reporting | ForEach-Object -Process {
               $_.pstypenames[0] = 'Empire.Logged.Event'
               $_
           }
        } else {
            Write-Warning -Message 'No resposnse received.'
        }
    }
    End{
    }
}


<#
.Synopsis
   Search logged events in a Empire server for a specified term.
.DESCRIPTION
   Search logged events in a Empire server for a specified term.
.PARAMETER Id
    Empire session Id of the session to use.
.PARAMETER Token
    Empire API token to use to execute the action.
.PARAMETER ComputerName
    IP Address or FQDN of remote Empire server.
.PARAMETER Port
    Port number to use in the connection to the remote Empire server.
.PARAMETER NoSSLCheck
    Do not check if the TLS/SSL certificate of the Empire is valid.
.EXAMPLE
   C:\PS> Search-EmpireLoggedEvent -Id 0 -Term ipconfig
   Search for the string ipconfig in the logged events message field.
.NOTES
    Licensed under BSD 3-Clause license
#>
function Search-EmpireLoggedEvent {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName='Session',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Int]
        $Id,
        
        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Token,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]
        $Port = 1337,
        
        [Parameter(Mandatory=$false)]
        [switch]
        $NoSSLCheck,
        
        # Search term
        [Parameter(Mandatory=$true)]
        [string]
        $Term
    )

    Begin {
        if ($NoSSLCheck) {
            DisableSSLCheck
        }
    }
    Process {
        
        switch ($PSCmdlet.ParameterSetName) {
            'session' { $sessionobj = Get-EmpireSession -Id $Id
                if ($sessionobj) {
                   $RequestOpts = @{}
                    $RequestOpts.Add('Method','Get')
                    $RequestOpts.Add('Uri', "https://$($sessionobj.host):$($sessionobj.port)/api/reporting/msg/$($Term)")
                    $RequestOpts.Add('ContentType', 'application/json')
                    $RequestOpts.Add('Body', @{'token'= $sessionobj.token})
                } else {
                    Write-Error -Message "Session not found."
                    return
                }
            }
            
            'Direct' {
                $RequestOpts = @{}
                $RequestOpts.Add('Method','Get')
                $RequestOpts.Add('Uri', "https://$($ComputerName):$($Port)/api/reporting/msg/$($Term)")
                $RequestOpts.Add('ContentType', 'application/json')
                $RequestOpts.Add('Body', @{'token'= $token})
            }
            Default {}
        }
        
        
        $response = Invoke-RestMethod @RequestOpts
        if ($response) {
           $response.reporting | ForEach-Object -Process {
               $_.pstypenames[0] = 'Empire.Logged.Event'
               $_
           }
        } else {
            Write-Warning -Message 'No resposnse received.'
        }
    }
    End{
    }
}


<#
.Synopsis
   Get logged credentials in a Empire server by a agent.
.DESCRIPTION
   Get logged credentials in a Empire server by a agent.
.PARAMETER Id
    Empire session Id of the session to use.
.PARAMETER Token
    Empire API token to use to execute the action.
.PARAMETER ComputerName
    IP Address or FQDN of remote Empire server.
.PARAMETER Port
    Port number to use in the connection to the remote Empire server.
.PARAMETER NoSSLCheck
    Do not check if the TLS/SSL certificate of the Empire is valid.
.EXAMPLE
   C:\PS> Get-EmpireLoggedCredential -Id 0
   Get all logged credentials.
.NOTES
    Licensed under BSD 3-Clause license
#>
function Get-EmpireLoggedCredential {
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName='Session',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Int]
        $Id,
        
        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Token,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $ComputerName,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Direct',
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]
        $Port = 1337,
        
        [Parameter(Mandatory=$false)]
        [switch]
        $NoSSLCheck
    )

    Begin {
        if ($NoSSLCheck) {
            DisableSSLCheck
        }
    }
    Process {
        
        switch ($PSCmdlet.ParameterSetName) {
            'session' { $sessionobj = Get-EmpireSession -Id $Id
                if ($sessionobj) {
                   $RequestOpts = @{}
                    $RequestOpts.Add('Method','Get')
                    $RequestOpts.Add('Uri', "https://$($sessionobj.host):$($sessionobj.port)/api/creds")
                    $RequestOpts.Add('ContentType', 'application/json')
                    $RequestOpts.Add('Body', @{'token'= $sessionobj.token})
                } else {
                    Write-Error -Message "Session not found."
                    return
                }
            }
            
            'Direct' {
                $RequestOpts = @{}
                $RequestOpts.Add('Method','Get')
                $RequestOpts.Add('Uri', "https://$($ComputerName):$($Port)/api/creds")
                $RequestOpts.Add('ContentType', 'application/json')
                $RequestOpts.Add('Body', @{'token'= $token})
            }
            Default {}
        }
        
        
        $response = Invoke-RestMethod @RequestOpts
        if ($response) {
           $response.creds | ForEach-Object -Process {
               $_.pstypenames[0] = 'Empire.Logged.Credential'
               $_
           }
        } else {
            Write-Warning -Message 'No resposnse received.'
        }
    }
    End{
    }
}
