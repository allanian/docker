# AWX LDAP, Active Directory
```
LDAP Server URI:
ldap://<server.fqdn>:389
eg: ldap://dc1.microsoft.com:389

LDAP Bind DN:
CN=<account name>,OU=<ou name>,DC=<domain name>,DC=<top level domain>
eg: CN=awx_service_account,OU=service accounts,DC=microsoft,DC=com

LDAP Bind Password
********************
eg: Password01

LDAP User DN Template:
blank

LDAP Group Type:
MemberDNGroupType

LDAP Require Group:
CN=<awx user group>,OU=<ou name>,DC=<domain name>,DC=<top level domain>
eg: CN=awx_user_group,OU=administration groups,DC=microsoft,DC=com

LDAP Deny Group:
blank

LDAP Start TLS:
Off

LDAP User Search:
[
 "DC=<domain name>,DC=<top level domain>",
 "SCOPE_SUBTREE",
 "(sAMAccountName=%(user)s)"
]
eg:
[
"DC=microsoft,DC=com",
"SCOPE_SUBTREE",
"(sAMAccountName=%(user)s)"
]

LDAP Group Search:
[
 "OU=<ou name>,DC=<domain name>,DC=<top level domain>",
 "SCOPE_SUBTREE",
 "(objectClass=group)"
]
eg:
[
"OU=administration groups,DC=microsoft,DC=com",
"SCOPE_SUBTREE",
"(objectClass=group)"
]
LDAP User Attribute Map:
{
 "first_name": "givenName",
 "last_name": "sn",
 "email": "mail"
}

# dont used it
LDAP User Flags by Group:
{
 "is_superuser": "cn=<super users group>,OU=<ou name>,DC=<domain name>,DC=<top level domain>"
}

# dont used it
LDAP Organization Map:
{
 "<Organisation name in AWX>": {
  "users": true,
  "admins": "OU=<org admins ou name>,OU=<ou name>,DC=<domain name>,DC=<top level domain>",
  "remove_admins": false,
  "remove_users": false
 }
}

LDAP Team Map
{
 "<team name 1>": {
  "organization": "<team name 1>",
  "users": "CN=<team group>,OU=<ou name>,DC=<domain name>,DC=<top level domain>",
  "remove": true
 },
 "<team name 2>": {
  "organization": "<team name 2>",
  "users": "CN=<team group>,OU=<ou name>,DC=<domain name>,DC=<top level domain>",
  "remove": true
 }
}

```
