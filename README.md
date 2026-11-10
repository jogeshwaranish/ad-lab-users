# AD lab users

30 fictional users for populating a test Active Directory. Names, usernames and passwords are made up; do not use them anywhere real.

- `ad_dummy_users.csv`: one row per user, with first/last name, username (`SamAccountName`), UPN, password, department, title and target OU.
- `Import-LabUsers.ps1`: creates the OUs (`Lab > Users > <Department>`) and the users.

Departments / OUs: IT, HR, Finance, Sales, Marketing, Engineering (5 users each).

## Usage

On a domain controller, in an elevated PowerShell:

```powershell
.\Import-LabUsers.ps1                     # domain lab.local
.\Import-LabUsers.ps1 -Domain corp.test   # any other domain
```

The script skips users that already exist, so it is safe to re-run.
