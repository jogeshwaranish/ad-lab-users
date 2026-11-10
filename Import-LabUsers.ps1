# Creates the users listed in ad_dummy_users.csv in the domain this machine belongs to.
# Run on a domain controller (or a machine with RSAT) as a Domain Admin.
#
#   -ParentOU     Distinguished name of an existing OU to put users under.
#                 Defaults to the root of your domain.
#   -NoDepartmentOUs   Put every user directly in -ParentOU instead of creating
#                      one sub-OU per Department value.
param(
    [string]$CsvPath = ".\ad_dummy_users.csv",
    [string]$ParentOU,
    [switch]$NoDepartmentOUs
)
Import-Module ActiveDirectory

$domain = Get-ADDomain                      # your current domain, detected automatically
$upnSuffix = $domain.DNSRoot
if (-not $ParentOU) { $ParentOU = $domain.DistinguishedName }

function Ensure-OU([string]$Name, [string]$Parent) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Parent -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $Name -Path $Parent -ProtectedFromAccidentalDeletion $false
        Write-Host "Created OU=$Name,$Parent"
    }
    "OU=$Name,$Parent"
}

foreach ($u in Import-Csv $CsvPath) {
    $path = if ($NoDepartmentOUs) { $ParentOU } else { Ensure-OU $u.Department $ParentOU }
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue) {
        Write-Host "Skipping $($u.SamAccountName): already exists"
        continue
    }
    New-ADUser -Name $u.DisplayName -GivenName $u.FirstName -Surname $u.LastName `
        -DisplayName $u.DisplayName -SamAccountName $u.SamAccountName `
        -UserPrincipalName "$($u.SamAccountName)@$upnSuffix" `
        -Department $u.Department -Title $u.Title -Path $path `
        -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) `
        -Enabled $true -ChangePasswordAtLogon $false
    Write-Host "Created $($u.SamAccountName) in $path"
}
