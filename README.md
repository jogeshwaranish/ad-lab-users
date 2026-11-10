# AD lab users

30 fictional users for populating a test Active Directory. Names, usernames and passwords are made up; do not use them anywhere real.

- `ad_dummy_users.csv`: first/last name, display name, username (`SamAccountName`), password, department and title. No domain or OU information, so it works with any domain.
- `Import-LabUsers.ps1`: creates the users in whatever domain the machine it runs on belongs to.

Departments: IT, HR, Finance, Sales, Marketing, Engineering (5 users each).

## Usage

On a domain controller, in an elevated PowerShell:

```powershell
# Detects your domain; creates one OU per department at the domain root
.\Import-LabUsers.ps1

# Put the department OUs under an OU you already have
.\Import-LabUsers.ps1 -ParentOU "OU=Staff,DC=yourdomain,DC=com"

# Put every user straight into one existing OU, no department OUs
.\Import-LabUsers.ps1 -ParentOU "OU=Staff,DC=yourdomain,DC=com" -NoDepartmentOUs
```

UPNs are built as `username@<your domain>`. The script skips users that already exist, so it is safe to re-run.
