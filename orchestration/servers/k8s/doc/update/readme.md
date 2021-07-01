# update all 
```
sudo yum install kubeadm --disableexcludes=kubernetes
kubeadm version

# DOC
план
обновляем мастер
на время обновления мастера, мастер не доступен, обновляем поочереди
обновляем воркеров
обновляем поочереди
или создаем новые воркеры, подключаем их к кластеру и выводим старые (актуально для облаков)

[preflight] Some fatal errors occurred:
	[ERROR CoreDNSUnsupportedPlugins]: CoreDNS cannot migrate the following plugins:

# check current config
kubectl -n kube-system get cm coredns -oyaml

        forward . /etc/resolv.conf {
           max_concurrent 1000
        }


kubectl -n kube-system edit cm coredns
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }

change to 
forward . /etc/resolv.conf

# run manual upgrade
kubeadm config images pull
kubeadm upgrade apply v1.20.4

ждем пока успешно обновится мастер
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.20.x". Enjoy!
[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.


#### для других мастер-нод, обновляем так
sudo kubeadm upgrade node

########Upgrade kubelet and kubectl
#Drain the node
kubectl drain node1 --ignore-daemonsets

# issue with dashboard, cant move pod with local storage
kubectl drain node1 --ignore-daemonsets --delete-emptydir-data

## UPGRADE KUBELET
yum install -y kubelet-1.20.4-0 kubectl-1.20.4-0 --disableexcludes=kubernetes
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# после обновления верните ноду из статуса DRAIN
kubectl uncordon node1


####Upgrade worker nodes
#Upgrade kubeadm
yum install -y kubeadm-1.20.4-0 --disableexcludes=kubernetes
sudo kubeadm upgrade node
# DRAIN NODE
kubectl drain <node-to-drain> --ignore-daemonsets
kubectl drain node2 --ignore-daemonsets

# issue with drain with k8s-dashboard and gitlab-runner
kubectl drain node2 --ignore-daemonsets --delete-local-data

#Upgrade kubelet and kubectl
yum install -y kubelet-1.20.4-0 kubectl-1.20.4-0 --disableexcludes=kubernetes
sudo systemctl daemon-reload
sudo systemctl restart kubelet
systemctl status kubelet
[root@node1 ~]# kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
node1   Ready    control-plane,master   34d   v1.20.4
kubelet --version
kubectl version
должна быть новая 20.4
# после обновления верните ноду из статуса DRAIN
kubectl uncordon node2





[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
W0326 11:41:14.299810   54526 utils.go:69] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]
kubectl -n kube-system get cm kubeadm-config -o yaml
export EDITOR=nano
kubectl -n kube-system edit cm kubeadm-config -o yaml

```






