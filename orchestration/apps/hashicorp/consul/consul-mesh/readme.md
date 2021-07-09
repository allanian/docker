# CONSUL FEDERATION 0.32.1
# DC1
helm delete consul -n consul
kubectl delete ns consul
kubectl create ns consul
kubectl -n consul delete secret consul-acl-bootstrap-token
kubectl -n consul create secret generic consul-gossip-encryption-key --from-literal=key=$(consul keygen)
kubectl -n consul create secret generic consul-acl-bootstrap-token --from-literal=token=111111111111111111111
helm upgrade --install -f dc1.yml -n consul consul hashicorp/consul
# crd
kubectl apply -f proxy.yml  -n consul
kubectl get proxydefaults global
# get federation secret
kubectl -n consul get secret consul-federation -o yaml > consul-federation-secret.yaml

# DC2
kubectl delete ns consul
kubectl create ns consul
kubectl -n consul apply -f consul-federation-secret.yaml
helm upgrade --install -f dc2.yml -n consul consul hashicorp/consul
# check
kubectl exec statefulset/consul-server -- consul members -wan
kubectl exec statefulset/consul-server -- consul catalog services -datacenter dc2
# go to ui and check
