function Start-AuthentictaionDashboardExample {
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
