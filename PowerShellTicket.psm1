function Start-UDDashboardAuthentictaionExample {
    Import-Module -Force UniversalDashboard

    $FormLogin = New-UDAuthenticationMethod -Endpoint {
        param([PSCredential]$Credentials)

        if ($Credentials.UserName -eq "Adam" -and $Credentials.GetNetworkCredential().Password -eq "SuperSecretPassword") {
            New-UDAuthenticationResult -Success -UserName "Adam"
        }

        New-UDAuthenticationResult -ErrorMessage $Credentials.GetNetworkCredential().Password
    }

    $MicorosftOAuthApplicationID = Get-PasswordstatePassword -ID 5415

    $MicrosoftLogin = New-UDAuthenticationMethod -AppId $MicorosftOAuthApplicationID.UserName -AppSecret $MicorosftOAuthApplicationID.Password -Provider Microsoft 

    $LoginPage = New-UDLoginPage -AuthenticationMethod @($FormLogin, $MicrosoftLogin)

    $MyDashboardPage = New-UDPage -Url "/myDashboard" -Endpoint {
        New-UDCard -Title "Welcome, $User" -Text "This is your custom dashboard."
    }

    $Dashboard = New-UDDashboard -LoginPage $LoginPage -Page @(
        $MyDashboardPage
    )

    Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AllowHttpForLogin
}

function Start-UDDashboardExamples {
    $Dashboard = . 'C:\Program Files\WindowsPowerShell\Modules\UniversalDashboard\1.6.1\poshud\dashboard.ps1'
    Start-UDDashboard -Dashboard $Dashboard
}

function Start-TicketDashBoard {
    $Dashboard = New-TicketDashboard
    Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AllowHttpForLogin
}

function New-TicketDashboard {
    $LoginPage = New-TicketLoginPage
    $MyDashboardPage = New-UDPage -Url "/myDashboard" -Endpoint {
        New-UDCard -Title "Welcome, $User" -Text "This is your custom dashboard."
    }

    New-UDDashboard -LoginPage $LoginPage -Page @(
        $MyDashboardPage
    )
}
function New-TicketLoginPage {
    $MicorosftOAuthApplicationID = Get-PasswordstatePassword -ID 5415
    $MicrosoftLogin = New-UDAuthenticationMethod -AppId $MicorosftOAuthApplicationID.UserName -AppSecret $MicorosftOAuthApplicationID.Password -Provider Microsoft 
    New-UDLoginPage -AuthenticationMethod $MicrosoftLogin
}

function New-TicketEntryForm {
    New-UDInput -Title "Echo" -SubmitText "Echo text" -Endpoint {
        param (
            [Parameter(Mandatory)][string]$Summary,
            [ValidateSet(1, 2, 3, 4,"Escalated")]$Priority,
            [ValidateSet(
                "Business Services",
                "eCommerce",
                "Item Management",
                "Technical Services"
            )]
            $Type,

            $SubType,
            $Category,
            $Note
        )

        New-UDInputAction -Toast $Message
    } -FontColor "black"

    New-UDInput -Title "New Work Order" -Id "Form" -Content {
        New-UDInputField -Type textbox -Name Summary
        New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
        New-UDInputField -Type 'select' -Name 'FavoriteLanguage' -Placeholder 'Favorite Programming Language' -Values @("PowerShell", "Python", "C#")
        New-UDInputField -Type 'radioButtons' -Name 'FavoriteEditor' -Placeholder @("Visual Studio", "Visual Studio Code", "Notepad") -Values @("VS", "VSC", "NP")
        New-UDInputField -Type 'textarea' -Name Note
    } -Endpoint {
        param($Email, $Newsletter, $FavoriteLanguage, $FavoriteEditor, $password, $notes)
    }
}

function Start-TestDashboard {
    $MyDashboardPage = New-UDPage -Url "/myDashboard" -Endpoint {
        New-UDCard -Title "Welcome, $User" -Text "This is your custom dashboard."
    }

    $Dashboard = New-UDDashboard -Page @(
        $MyDashboardPage
    )
    Get-UDDashboard | Stop-UDDashboard
    $Dashboard = New-UDDashboard -Title "test" -Content {
        New-UDRow -Columns { 
            New-UDColumn -Size 8 {
                New-UDElement -Id "message" -Tag "input" -Attributes @{
                    type = "text"
                    value = ''
                    placeholder = "Type a chat message"
                }
            }
        }
    }

    Get-UDDashboard | Stop-UDDashboard
    $dashboard = New-UDDashboard -Title "test" -Content {
        New-UDRow -Columns { 
            New-UDColumn -Size 8 {
                New-UDElement -Id "message" -Tag "input" -Attributes @{
                    type = "text"
                    value = ''
                    placeholder = "Type a chat message"
                }
            }
        }
    }

    Get-UDDashboard | Stop-UDDashboard
    $dashboard = New-UDDashboard -Title "PowerShellTicket" -Content {
        New-UDElement -Tag div -Attributes @{class="input-field"} -Content {
            New-UDElement -Id "message" -Tag "input" -Attributes @{
                type = "text"
                name = "Message"
            }
            New-UDElement -Id "messagelabel" -Tag label -Attributes @{for="message"; class=""} -Content {"Message"}
        }
        
        New-UDInput -Title "Summary" -Endpoint {
            param (
                $Summary
            )
            $Summary
        }
        New-UDInput -Title "Notes" -Endpoint {
            param (
                $Notes
            )
            $Notes        
        }
        New-UDInput -Title "New Work Order" -Id "Form" -Content {
            New-UDInputField -Type textbox -Name Summary
            New-UDInputField -Type textbox -Name Summary2
            New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
        } -Endpoint {}
    } 
    Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AllowHttpForLogin
}

function New-UDElementInput {
    [CmdletBinding()]
    param (
        $BackgroundColor,
        $Content,
        $DebugEndpoint,
        [Parameter(Mandatory)]$Endpoint,
        $FontColor,
        $Id,
        $SubmitText,
        $Title
    )
    $UDCardParameters = $PSBoundParameters | ConvertFrom-PSBoundParameters -Property BackgroundColor,FontColor,Id,Title -AsHashTable
    if (-not $Content) {
        [String]$OnClick

        New-UDCard @UDCardParameters -Content {
            $function:GetParameters___ = $Endpoint
            $EndpointParametersHash = (Get-Command GetParameters___ -Type Function).Parameters
            $EndpointParameters = $EndpointParametersHash.Keys | ForEach-Object {$EndpointParametersHash[$_]}

            foreach ($EndpointParameter in $EndpointParameters) {
                $OuterUDElementParameters = if ($EndpointParameter.ParameterType.Name -eq "Boolean") {
                    @{
                        Tag = "p"
                    }
                } else {
                    @{
                        Tag = "div"
                        Attributes = @{class="input-field"}
                    }
                }

                New-UDElement @OuterUDElementParameters -Content {
                    New-UDElement -Id $EndpointParameter.Name -Tag "input" -Attributes @{
                        type = if ($EndpointParameter.ParameterType.Name -eq "Boolean") {
                            "checkbox"
                        } else {
                            "text"
                        }
                        name = $EndpointParameter.Name
                    }
                    New-UDElement -Id "$($EndpointParameter.Name)label" -Tag label -Attributes @{for=$EndpointParameter.Name; class=""} -Content {$EndpointParameter.Name}
                }

                $OnClick += "`$$($EndpointParameter.Name) = (Get-UDElement -Id '$($EndpointParameter.Name)').Attributes['value']`r`n"
            }
           
            $RegexToMatchParamBlock = [regex]::new(@"
(?x)
\s*param\s*
    \(                      # First '('
        (?:                 
        [^()]               # Match all non-braces
        |
        (?<open> \( )       # Match '(', and capture into 'open'
        |
        (?<-open> \) )      # Match ')', and delete the 'open' capture
        )+
        (?(open)(?!))       # Fails if 'open' stack isn't empty!

    \)                      # Last ')'
"@)
            $EndpointWithoutParam = $Endpoint.ToString() -replace $RegexToMatchParamBlock, ""
            $OnClick += $EndpointWithoutParam

            New-UDElement -Tag div -Attributes @{class="row"} -Content {
                New-UDElement -Tag div -Attributes @{class="col s12 right-align"} -Content {
                    New-UDElement -Tag a -Attributes @{
                        href="#!"
                        class="btn"
                        onClick = [ScriptBlock]::Create($OnClick)
                    } -Content {"Submit"}
                }
            }
        }
    } else {
        New-UDCard -UDCardParameters -Content $Content 
    }
}

function Invoke-DashboardTesting1234 {
    
    Get-UDDashboard | Stop-UDDashboard
    $dashboard = New-UDDashboard -Title "PowerShellTicket" -Content {
        New-UDElementInput -Title "Summary" -Endpoint {param ($SummaryParam)}

        New-UDInput -Title "Summary" -Endpoint {
            param (
                $SummaryParam,
                [Bool]$Checkbox
            )
            $Summary
        }
        New-UDElementInput -Title "Summary3" -Endpoint {
            param ($Summary3Param,[Bool]$BoolParam)
            Add-UDElement -ParentId "Summary3" -Content {
                New-UDElement -Tag "p" -Content {
                    "Add new element at $(Get-Date)"
                }
            }
        }
        New-UDInput -Title "New Work Order" -Id "Form" -Content {
            New-UDInputField -Type textbox -Name Summary
            New-UDInputField -Type textbox -Name Summary2
            New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
        } -Endpoint {}
    } 
    Start-UDDashboard -Dashboard $Dashboard -Port 10000 -AllowHttpForLogin
}

function New-TestInputForm {
    New-UDCard -Title Summary -Content {
        New-UDElementInput
    }
}

function New-TervisUDElementInput {
    param (
        [ValidateSet(
            "textbox",
            "checkbox",
            "select",
            "radioButtons",
            "textarea"
        )]$Type,
        $onClick
    )
    New-UDElement -Tag input Attributes @{
        type = $Type
        placeholder = "Type a chat message"
        onClick = $onClick
    }
}