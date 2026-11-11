#Requires -Modules ActiveDirectory

$orgs = (Get-ADOrganizationalUnit -Filter *).Name

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
			New-ADUser -Name $($user.FirstName + $user.LastName) -Path "OU=$OU,DC=onuzaki,DC=baka" -AccountPassword $pw -SamAccountName $($user.SamAccountName)
			Write-Host "Created the user"
		}
		$user_index += 5
	}
}
