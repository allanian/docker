
### Keycloak
#### Realm
Add realm company
go to that realm
#### LDAP
go to federation and add LDAP
| Option | Value | description |
| ------ | ------ | ------ |
| Console Display Name | company.ru |
| Edit Mode | READ_ONLY | only read users from AD |
| Vendor | Active Directory | vendor |
| Username LDAP Attribute | sAMAccountName |
| RDN LDAP Attribute | cn,sAMAccountName,mail | атрибуты по которым будем искать юзеров |
| UUID LDAP attribute | objectGUID |
| User Object Classes | person, organizationalPerson, user |
| Connection URL | ldap://server.company.ru:389 |
| Users DN | CN=Users,DC=company,DC=ru | path to user folder |
| Search Scope | Subtree | search in folder recursive |
| Bind Type | simple | |
| Bind DN | CN=keycloak,CN=Users,DC=company,DC=ru | |
| Bind Credential | QWE123qwe |

# check here (see realm in URL)
http://keycloak.company.ru/auth/realms/company/account/#/


