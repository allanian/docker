# policy
nano it.hcl
path "secret/data/IT" {
capabilities = ["create", "read", "update", "delete", "list"] }
# write policy
vault policy write IT it.hcl
# enable auth ldap
vault auth enable ldap
# write auth method
vault write auth/ldap/config \
    url="ldap://rv-dc01.company.ru:389" \
	binddn="CN=Vault,OU=Служебные учетные записи,DC=company,DC=ru" \
	bindpass='QWE123qwe' \
	userattr=sAMAccountName \
    userdn="OU=Users,DC=rendez-vous,DC=ru" \
    groupdn="CN=Vault_Group,OU=Служебные учетные записи,DC=rendez-vous,DC=ru" \
	groupfilter="(&(objectClass=group)(member={{.UserDN}}))" \
	groupattr="memberOf" \
	use_token_groups="false" \
    insecure_tls=true \
    starttls=false
	
# Map the Vault IT policy to the Vault_Group AD group:
vault write auth/ldap/groups/Vault_Group policies=IT
# Test Vault AD Authentication:
vault login -method=ldap username='46653'

# Confirm your AD user has the permissions set in the IT Vault policy:
vault token capabilities secret/data/IT
