# VAULT 
# start vault
```
systemctl start vault
```
# init Vault
```
vault operator init
vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.7.2
Storage Type       file
HA Enabled         false
```
# unseal vault
```
export VAULT_ADDR="http://localhost:8200"
vault operator unseal <token1>
vault operator unseal <token2>
vault operator unseal <token3>
vault login <main token>


# LOGIN METHODS
# View the current authentication methods. Initially, there should only be `/token`
vault kv get sys/auth
# Enable userpass auth
vault auth enable userpass
# Enable ldap auth
vault auth enable ldap



```
# create secret engine
```
vault secrets list
vault secrets enable -path=iam_secret kv
```

# create policy
```
nano /tmp/iam-policy
path "iam_secret/*" {
  capabilities = ["create", "read", "list", "update"]
}
vault policy write iam /tmp/iam-policy
vault policy list
vault policy read iam

#Create users
vault kv put auth/userpass/users/sahil policies=default,iam password=#fsdE123qwe
```
