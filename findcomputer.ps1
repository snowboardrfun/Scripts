#############################################################################
#       Author: David Westmark    
#       Date: 3/7/2019
#       Satus: Find Computers
#       Description: Find Computer
#############################################################################

$Name = Read-Host "Enter Name"
$NewName = "*" + $Name + "*"
$Properties = @('Name', 'Description', 'Enabled', 'CanonicalName', 'OperatingSystem', 'OperatingSystemServicePack', 'LastLogonDate', 'PasswordLastSet', 'lockedout')

get-adcomputer -Filter {description -like $NewName} -Properties $Properties | Select $Properties 