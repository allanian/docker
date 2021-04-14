# AWX
## AWX k8s operator
```
https://github.com/ansible/awx-operator/blob/devel/README.md
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/devel/deploy/awx-operator.yaml
kubectl get pods
# Once the Operator is running, you can now deploy AWX by creating a simple YAML file:
cat myawx.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  tower_ingress_type: Ingress
  tower_hostname: awx1.company.ru
  tower_admin_user: admin
  tower_admin_email: admin@example.com

kubectl apply -f myawx.yml
kubectl logs -f awx-operator-f768499d-qbqcg
kubectl get pods

# ingress
export EDITOR=nano
kubectl get ingress awx-ingress
kubectl edit ingress awx-ingress
#change host: awx.example.com to your url

kubectl get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode
4Csv6rYGd29k8MhdvHzPimRw7YcbO6GT
```

## AWX LDAP, Active Directory
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
