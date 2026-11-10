# Creates the OUs and users listed in ad_dummy_users.csv.
# Run on a domain controller (or a machine with RSAT) as a Domain Admin.
# The CSV assumes the domain is lab.local; change -Domain if yours differs.
param(
    [string]$CsvPath = ".\ad_dummy_users.csv",
    [string]$Domain  = "lab.local"
)
Import-Module ActiveDirectory

$domainDN = (Get-ADDomain -Identity $Domain).DistinguishedName
$users = Import-Csv $CsvPath

function Ensure-OU([string]$Name, [string]$Parent) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Parent -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Name -Path $Parent -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU=$Name,$Parent"
    }
    "OU=$Name,$Parent"
}

$labOU   = Ensure-OU "Lab" $domainDN
$usersOU = Ensure-OU "Users" $labOU

foreach ($u in $users) {
    $ouPath = Ensure-OU $u.Department $usersOU
    $upn = "$($u.SamAccountName)@$Domain"
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue) {
        Write-Host "Skipping $($u.SamAccountName): already exists"
        continue
    }
    New-ADUser -Name $u.DisplayName -GivenName $u.FirstName -Surname $u.LastName `
        -DisplayName $u.DisplayName -SamAccountName $u.SamAccountName -UserPrincipalName $upn `
        -Department $u.Department -Title $u.Title -Path $ouPath `
        -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) `
        -Enabled $true -ChangePasswordAtLogon $false
    Write-Host "Created $($u.SamAccountName) in $ouPath"
}
