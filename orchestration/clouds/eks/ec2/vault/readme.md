```
helm repo add hashicorp https://helm.releases.hashicorp.com

export region=us-east-2 VAULT_AWSKMS_SEAL_KEY_ID=qweqwe AWS_ACCESS_KEY_ID=qwe AWS_SECRET_ACCESS_KEY="qwe" env=dev
# VAULT with Consul backend 
kubectl create ns vault

# FOR AUTO_UNSEAL with AWS KMS
kubectl -n vault delete secret eks-creds
# FOR AUTO UNSEAL VAULT IN AWS
kubectl -n vault create secret generic eks-creds \
    --from-literal=VAULT_SEAL_TYPE="awskms" \
    --from-literal=AWS_REGION=$region \
    --from-literal=VAULT_AWSKMS_SEAL_KEY_ID=$VAULT_AWSKMS_SEAL_KEY_ID \
    --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# CA from consul into secret to vault
kubectl -n vault delete secret consul-client-ca
kubectl -n vault create secret generic consul-client-ca --from-literal=ca="$(kubectl -n consul exec consul-server-0 -- curl -sk https://localhost:8501/v1/connect/ca/roots | jq -r .Roots[0].RootCert)"
# consul token for vault
kubectl -n vault delete secret consul-access-token
kubectl -n vault create secret generic consul-access-token --from-literal=consul.token="$(kubectl -n consul get secret consul-bootstrap-acl-token -o jsonpath={.data.token} | base64 -d)"

# install
helm upgrade --install vault --namespace vault --values values_$env.yaml hashicorp/vault
# uninstall
helm -n vault delete vault


# TOKENS
vault operator init


# AUTOUNSEAL just add env variables to helm vault
# VAULT AUTOUNSEAL WITH AWS KMS
https://us-east-2.console.aws.amazon.com/kms/home?region=us-east-2#/kms/home
create key -
symmetric
KMS
Alias - vault
Key administrators - my account
Define key usage permissions - my account
get KEY ID and create eks-creds with vars
# then, just create secret from step above - kubectl -n vault create secret generic eks-cred
after start do 1 time, vault operator init
then delete pod vault
and after recreate its autounsealed!


```
[root@li77-19 vault]# kubectl -n vault delete secret eks-creds
Error from server (NotFound): secrets "eks-creds" not found

```
