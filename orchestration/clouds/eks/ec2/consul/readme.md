
```
export env=qa
helm repo add hashicorp https://helm.releases.hashicorp.com
kubectl create ns consul
kubectl -n consul create secret generic consul-gossip-encryption-key --from-literal=key=$(consul keygen)
# add acl token
kubectl -n consul create secret generic consul-acl-bootstrap-token --from-literal=token=49792521-8362-f878-5a32-7405f1483838
helm upgrade --install -f values_$env.yaml -n consul consul hashicorp/consul
# HOW GET TOKEN ACL
$ sudo apt install jq
kubectl get secret -n consul consul-bootstrap-acl-token -o json | jq -r '.data.token' | base64 -d

https://consul-dev.company.com/ui/api/services

```
