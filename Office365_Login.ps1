#creds
$TenantUserName = "dwestmark@plygem.onmicrosoft.com"
$TenantPassword = cat "C:\O365\key\ExchangeNerd.key" | ConvertTo-SecureString
$TenantCredentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $TenantUserName, $TenantPassword

#Log into Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $TenantCredentials -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $TenantCredentials