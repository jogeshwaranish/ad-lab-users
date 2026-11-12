#Requires -Modules ActiveDirectory

$orgstc = @("HR","IT","Service Accounts", "Workstations", "Servers", "Finance")

$orgs = (Get-ADOrganizationalUnit -Filter *).Name

foreach($org in $orgs) {
	if ($org -ne "Domain Controllers"){
		Set-ADOrganizationalUnit -Identity  "OU=$org,DC=onuzaki,DC=baka" -ProtectedFromAccidentalDeletion $false
		Remove-ADOrganizationalUnit -Identity "OU=$org,DC=onuzaki,DC=baka" -Recursive -Confirm:$false
		Write-Host "Removed an organizational unit"
	}
}

foreach($ou in $orgstc) {
	New-ADOrganizationalUnit -Name "$ou" -Path "DC=onuzaki,DC=baka"

}


$users = Import-Csv -Path "C:\Users\Administrator\Downloads\ad_dummy_users.csv"

#foreach ($user in $users) {
#	Write-Host "$($user.FirstName)"
#}

$user_index = 0

foreach ($OU in $orgs) {
	if ($OU -ne "Domain Controllers"){
		if ((Get-ADUser -Filter * -SearchBase "OU=$OU,DC=onuzaki,DC=baka")) {
			Write-Host "There exists users already in $OU"
			$pastusers = Get-ADUser -Filter * -SearchBase "OU=$OU,DC=onuzaki,DC=baka"
			foreach($us in $pastusers) {
				Remove-ADUser $us
				Write-Host "Removed a user"
			}
		}
		for ($i = 0 + $user_index; $i  -le 4+$user_index; $i++) {
			$user = $users[$i]
			$pw = ConvertTo-SecureString $($user.Password) -AsPlainText -Force
			#New-ADUser -Name $($user.FirstName + $user.LastName) -Path "OU=$OU,DC=onuzaki,DC=baka" -AccountPassword $pw -SamAccountName $($user.SamAccountName) -Title $($user.Title) -Enabled $true
			Write-Host "Created the user"
		}
		$user_index += 5
	}
}
