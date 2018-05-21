Get-UDDashboard | Stop-UDDashboard

$loginPage = New-UDLoginPage -AuthenticationMethod @(
    New-UDAuthenticationMethod -Endpoint {
        param([PSCredential]$Credentials)

        New-UDAuthenticationResult -Success -UserName $Credentials.UserName
    }   
) 

$dashboard = New-UDDashboard -Title "PowerShell Universal Dashboard Chatroom" -Content {
    New-UDRow -Columns { 
        New-UDColumn -Size 8 {
            New-UDElement -Id "message" -Tag "input" -Attributes @{
                type = "text"
                value = ''
                placeholder = "Type a chat message"
            }
        }
    }
} -LoginPage $LoginPage -EndpointInitializationScript {
    Import-Module InvokeQuery
    $ConnectionString = "User Id=postgres;host=localhost;Database=udchatroom"
}

Start-UDDashboard -Port 10001 -Dashboard $dashboard -AllowHttpForLogin