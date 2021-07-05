# ADD NEW NODE
```
export version="1.20.7"
curl -LO https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
ln -s /usr/local/bin/kubectl /usr/bin
kubectl version --client



# DELETE NODE
# Mark node "foo" as unschedulable.
kubectl cordon foo
# drain node foo
kubectl drain foo --ignore-daemonsets
# remove node foo
kubectl delete node foo
# check nodes
kubectl get nodes

# connect to deleted node!

# reset all
kubeadm reset

# ADD NODE
# on master get token
kubeadm token create --print-join-command

kubeadm join 10.3.3.58:6443 --token test     --discovery-token-ca-cert-hash sha256:test
# LABEL NODE
kubectl label node
```
