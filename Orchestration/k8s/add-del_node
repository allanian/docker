```

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
