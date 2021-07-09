# STEP 1
1) VAULT BETBEEN CLOUDS WITH CONSUL HA
consul HA dont sync kv-storage between datacenter

# VAULT IN DIFFERENT CLOUDS WITH CONSUL HA

# vault1
kubectl delete ns vault
kubectl create ns vault
export region=us-east-2 VAULT_AWSKMS_SEAL_KEY_ID="     " AWS_ACCESS_KEY_ID="    " AWS_SECRET_ACCESS_KEY="  " env=dc1
kubectl -n vault delete secret eks-creds
kubectl -n vault create secret generic eks-creds \
    --from-literal=VAULT_SEAL_TYPE="awskms" \
    --from-literal=AWS_REGION=$region \
    --from-literal=VAULT_AWSKMS_SEAL_KEY_ID=$VAULT_AWSKMS_SEAL_KEY_ID \
    --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# Vault with consul backend, CA from consul into secret to vault
kubectl -n vault delete secret consul-client-ca
kubectl -n vault create secret generic consul-client-ca --from-literal=ca="$(kubectl -n consul exec consul-server-0 -- curl -sk https://localhost:8501/v1/connect/ca/roots | jq -r .Roots[0].RootCert)"
# consul token for vault
kubectl -n vault delete secret consul-access-token
kubectl -n vault create secret generic consul-access-token --from-literal=consul.token="$(kubectl -n consul get secret consul-bootstrap-acl-token -o jsonpath={.data.token} | base64 -d)"
helm upgrade --install vault --namespace vault --values values_qa.yaml hashicorp/vault

# vault2
# Vault with consul backend, CA from consul into secret to vault
kubectl -n vault delete secret consul-client-ca
kubectl -n vault create secret generic consul-client-ca --from-literal=ca="$(kubectl -n consul exec consul-server-0 -- curl -sk https://localhost:8501/v1/connect/ca/roots | jq -r .Roots[0].RootCert)"
# consul token for vault
kubectl -n vault delete secret consul-access-token
kubectl -n vault create secret generic consul-access-token --from-literal=consul.token="$(kubectl -n consul get secret consul-bootstrap-acl-token -o jsonpath={.data.token} | base64 -d)"
helm upgrade --install vault --namespace vault --values values_test.yaml hashicorp/vault



########### INIT / UNSEAL
# Initialize and unseal Vault
kubectl -n vault exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
#Create a variable named VAULT_UNSEAL_KEY to capture the Vault unseal key.
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
echo $VAULT_UNSEAL_KEY
# unseal vault-0 pod
kubectl -n vault exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl -n vault exec vault-0 -- vault status
# save secret in vault
#cat cluster-keys.json | jq -r ".root_token"
CLUSTER_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")
echo $CLUSTER_ROOT_TOKEN
kubectl -n vault exec vault-0 -- vault login $CLUSTER_ROOT_TOKEN
kubectl -n vault exec --stdin=true --tty=true vault-0 -- /bin/sh
vault secrets enable -path=secret kv-v2
vault kv put secret/webapp/config username="static-user" password="static-password"
vault kv get secret/webapp/config
exit
