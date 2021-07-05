# ADD NEW NODE
```
######################
# ON MASTER NODE
######################
# get token
kubeadm token create --print-join-command
kubeadm join 10.3.3.58:6443 --token qwewqewqeqeqe --discovery-token-ca-cert-hash sha256:qweq12312321312321321312312312

######################
# ON SLAVE MODE
######################
# install docker
systemctl enable docker.service
systemctl start docker.service
docker ps -a
# install k8s tools
export version="1.20.7"
yum install kubeadm-${version} kubelet-${version} kubectl-${version} --disableexcludes=kubernetes
kubectl version --client
kubeadm version
systemctl start kubelet.service
systemctl enable kubelet.service
kubeadm join 10.3.3.58:6443 --token qwewqewqeqeqe --discovery-token-ca-cert-hash sha256:qweq12312321312321321312312312

# on master node you can check it with:
kubectl get nodes

```
# DELETE NODE
```
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
