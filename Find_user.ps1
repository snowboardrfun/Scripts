$Name = Read-Host "Enter Name or EID"

$OUsToSearch =
  "OU=Sites,DC=plygempw,DC=local",
  "OU=Administrators,DC=plygempw,DC=local",
  "CN=Users,DC=plygempw,DC=local",
  "OU=Terminated Users,DC=plygempw,DC=local"

foreach($Path in $OUsToSearch){
    get-aduser -SearchBase $Path -Filter {GivenName -eq $Name} -Properties employeeid, City | Select name, SamAccountname, City, employeeid, enabled
    get-aduser -SearchBase $Path -Filter {surname -eq $Name} -Properties employeeid, City | Select name, SamAccountname, City, employeeid, enabled
    get-aduser -SearchBase $Path -Filter {employeeid -like $Name} -Properties employeeid, City | Select name, SamAccountname, City, employeeid, enabled
}