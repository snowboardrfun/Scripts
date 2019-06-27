#Script created by David Westmark
#Update 8/15/2017
 
# Gets all of the users info to be copied to the new account
 
#may have to import-module activedirectory

$CopyUser = Read-Host "Copy What User"
$firstname = Read-Host "First Name"
$Lastname = Read-Host "Last Name"
$MiddleName = Read-Host "Middle Inital"
$EmployeeID = Read-Host "Enter Employee ID"
$Title = Read-Host "Enter Title"
$Password = "Password19"
$SecurePassword = ConvertTo-SecureString $Password –asplaintext –force
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$newuserfinitial = $firstname.substring(0,1)
$name = Get-AdUser -Identity $CopyUser -Properties *
$email = "$firstname" + "." + "$LastName"+"@plygem.com"
$AliasEmail = $Firstname.substring(0,1)+"$Lastname"
$HomeDrive = 'U:'

#Makes Username
$Deployusername = Read-Host -prompt "
1) Is Lastname at least 6 letters?
2) Is Lastname less then 6 letters aka Enter User Manually?
3) Is Lastname less then 6 letters aka Enter User Manually and no Middle name?
4) Does User have no Middle Name?
Please Select Number"
switch($Deployusername)
{
     1{
    $UserName = $Lastname.substring(0,6)+$firstname.substring(0,1)+$Middlename.substring(0,1)
    $Display = "$firstname" + " " + "$MiddleName." + " " + "$LastName"
    $FullName = "$firstname" + " " + "$MiddleName." + " " + "$LastName"
    $NewName = "$firstname$MiddleName$Lastname"
    }
    2{
    $UserName = Read-Host "Enter User Name"
    $Display = "$firstname" + " " + "$MiddleName." + " " + "$LastName"
    $FullName = "$firstname" + " " + "$MiddleName." + " " + "$LastName"
    $NewName = "$firstname$MiddleName$Lastname"
    }
    3{
    $UserName = Read-Host "Enter User Name"
    $Display = "$firstname" + " " + "$LastName"
    $FullName = "$firstname" + " " + "$LastName"
    $NewName = "$firstname$Lastname" 
    }
    4{
    $UserName = $Lastname.substring(0,6)+$firstname.substring(0,1)
    $Display = "$firstname" + " " + "$LastName"
    $FullName = "$firstname" + " " + "$LastName"
    $NewName = "$firstname$Lastname"
    }

}


#split on the first comma, save everything after the username to $path to make OU  
$OU = (Get-AdUser $CopyUser).distinguishedName.Split(',',2)[1]

#Picks Site
$Option = Read-Host -prompt "
1) Auburn
2) Corona
3) Sacramento
4) EXIT
Please Select Number"
switch($Option)
{
     1{
    $location = "auburn"
    $sublocation = "Auburn"
    $doublesub = "waaubwsfiles001"
    }
    2{
    $location = "corona"
    $sublocation = "corona"
    $doublesub = "cacorwsfiles001"
    }
    3{
    $location = "sacramento"
    $sublocation = "Sacramento"
    $doublesub = "casacwsfiles001"
    }
    4{write-warning "Script Is Now Ending!"
	Exit}
}


# Creates the user from the copied properties
write-host "Creating New User" -ForegroundColor cyan
New-ADUser -SamAccountName $UserName `
-DisplayName $Display `
-Name $FullName `
-GivenName $firstname `
-Surname $lastname `
-Initials $MiddleName `
-AccountPassword $SecurePassword `
–userPrincipalName $UserName@plygempw.com -EmployeeID $EmployeeID `
-EmailAddress $email `
-Company $name.Company `
-Department $name.Department `
-Manager $name.Manager `
-title $Title `
-Description $name.Description `
-HomePage $name.HomePage `
-Office $name.Office -City $name.city `
-PostalCode $name.postalcode `
-Fax $name.fax `
-State $name.State `
-StreetAddress $name.StreetAddress `
-OfficePhone $name.OfficePhone `
-homedrive $HomeDrive -homedirectory "\\plygempw.local\$location\users\$UserName" -Enabled $true `
-Path $OU `
-Country US

write-host "Users username is: $UserName" -ForegroundColor Green

#Copy Groups over 
write-host "Copying Group Memberships" -ForegroundColor cyan
$groups = (GET-ADUSER –Identity $name –Properties MemberOf).MemberOf
foreach ($group in $groups) {
Add-ADGroupMember -Identity $group -Members $UserName
}
 
#make U drive with permissions
#Makes Directory
write-host "Creating User drive and Assigning Permissions" -ForegroundColor cyan
New-Item -ItemType directory -Path \\$doublesub\$sublocation\Users\$UserName
#Assigns Permissions
$permissions = "plygempw.local\$UserName","FullControl","ContainerInherit,ObjectInherit","none","Allow"
$rule=new-object System.Security.AccessControl.FileSystemAccessRule $permissions
$acl = Get-ACL \\$doublesub\$sublocation\Users\$UserName
$acl.SetAccessRule($rule)
Set-ACL -Path \\$doublesub\$sublocation\Users\$UserName -AclObject $acl

#Adds @plygem alias
write-host "Creating proxyaddresses" -ForegroundColor cyan
$proxyAddresses = "$AliasEmail" + "@plygemwindows.com"
Set-ADUser -Identity $UserName -Add @{
  'proxyAddresses' = $proxyAddresses | % { "smtp:$_" }
}

#Set Primary Address
Set-ADUser -Identity $UserName -Add @{
    'proxyAddresses' = $email | % { "SMTP:$_" }
}

#set the msExchRecipientType (and other) Exchange related attributes
#Enable-RemoteMailbox $UserName -RemoteRoutingAddress $UserName@plygem.mail.onmicrosoft.com

write-host "New User Creation is Completed!" -ForegroundColor cyan
write-host "Enable-RemoteMailbox $UserName -RemoteRoutingAddress $UserName@plygem.mail.onmicrosoft.com"