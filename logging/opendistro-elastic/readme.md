# LDAP WINDOWS AD
```
edit config.yml
set connection string to your LDAP server
define next vars:
bind_dn
password
# users base
userbase
# group base
rolebase
rolesearch: "(member={0})"
```
