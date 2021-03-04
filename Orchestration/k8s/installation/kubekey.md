# Kubekey
```
- [Main](https://github.com/allanian/docker/blob/master/Orchestration/k8s/installation/kubekey.md#KUBEKEY)   
- [Install](https://github.com/allanian/docker/blob/master/Orchestration/k8s/installation/kubekey.md#Install)   
- [Dashboard](https://github.com/allanian/docker/blob/master/Orchestration/k8s/installation/kubekey.md#dashboard)    
- [Ingress-Nginx](https://github.com/allanian/docker/blob/master/Orchestration/k8s/installation/kubekey.md#Ingress-Nginx)   
- [Additional](https://github.com/allanian/docker/blob/master/Orchestration/k8s/installation/kubekey.md#Additional)
```
## Install
```
# before creating k8s cluster, run ansible playbook with kubekey_docker role (its install that soft: docker,socan,openssl,tc and other tools)
ansible-playbook -i inventory/install_inventory -u root playbooks/install_soft.yml
```
```
# Install kubekey
# check version here - https://github.com/kubesphere/kubekey/releases
https://github.com/kubesphere/kubekey
curl -sfL https://get-kk.kubesphere.io | VERSION=v1.0.1 sh -
chmod +x kk
# create config for install k8s v1.19.0 (check versions here https://github.com/kubesphere/kubekey/blob/master/docs/kubernetes-versions.md)
./kk create config --with-kubernetes v1.19.0 --with-kubesphere version v3.0.0
nano config-sample.yaml
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
  - {name: node1, address: 172.1.1.1, internalAddress: 172.1.1.1, user: root, password: password}
  - {name: node2, address: 172.1.1.2, internalAddress: 172.1.1.2, user: root, password: password}
  - {name: node3, address: 172.1.1.3, internalAddress: 172.1.1.3, user: root, password: password}
  roleGroups:
    etcd:
    - node1
    master: 
    - node1
    worker:
    - node2
    - node3
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: ""
    port: "6443"
  kubernetes:
    version: v1.19.0
    imageRepo: kubesphere
    clusterName: cluster.local
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: []
    insecureRegistries: []
  addons: []


---
apiVersion: installer.kubesphere.io/v1alpha1
kind: ClusterConfiguration
metadata:
  name: ks-installer
  namespace: kubesphere-system
  labels:
    version: v3.0.0
spec:
  local_registry: ""
  persistence:
    storageClass: ""
  authentication:
    jwtSecret: ""
  etcd:
    monitoring: true
    endpointIps: localhost
    port: 2379
    tlsEnable: true
  common:
    es:
      elasticsearchDataVolumeSize: 20Gi
      elasticsearchMasterVolumeSize: 4Gi
      elkPrefix: logstash
      logMaxAge: 7
    mysqlVolumeSize: 20Gi
    minioVolumeSize: 20Gi
    etcdVolumeSize: 20Gi
    openldapVolumeSize: 2Gi
    redisVolumSize: 2Gi
  console:
    enableMultiLogin: false  # enable/disable multi login
    port: 30880
  alerting:
    enabled: false
  auditing:
    enabled: false
  devops:
    enabled: false
    jenkinsMemoryLim: 2Gi
    jenkinsMemoryReq: 1500Mi
    jenkinsVolumeSize: 8Gi
    jenkinsJavaOpts_Xms: 512m
    jenkinsJavaOpts_Xmx: 512m
    jenkinsJavaOpts_MaxRAM: 2g
  events:
    enabled: false
    ruler:
      enabled: true
      replicas: 2
  logging:
    enabled: false
    logsidecarReplicas: 2
  metrics_server:
    enabled: true
  monitoring:
    prometheusMemoryRequest: 400Mi
    prometheusVolumeSize: 20Gi
  multicluster:
    clusterRole: none  # host | member | none
  networkpolicy:
    enabled: false
  notification:
    enabled: false
  openpitrix:
    enabled: false
  servicemesh:
    enabled: false

# create cluster with kubesphere v3.0.0
./kk create cluster -f config-sample.yaml

# go to master node
export PATH=$PATH:/usr/local/bin
kubectl get nodes
```

# dashboard
```
# releases here
# https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.4.2
# https://github.com/kubernetes/dashboard/releases/tag/v2.2.0
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
kubectl get svc -n kubernetes-dashboard
```
### change to nodeport
```
kubectl edit svc kubernetes-dashboard -o yaml -n kubernetes-dashboard
kubectl get svc -n kubernetes-dashboard
https://10.3.3.216:30943/
```
### RBAC for Dashboard
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
# get token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


# ADD NGINX INGRESS
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx

# check
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- /nginx-ingress-controller --version
```
# Ingress-Nginx
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
# check
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')  kubectl exec -it $POD_NAME -- /nginx-ingress-controller --version
```

# Gitlab integration
```
go to admin console of gitlab / k8s / add integration
cluster name - test
env scope - test
api url - https://10.3.3.215:6443
```
#### CA certificate
List the secrets with 
```
kubectl get secrets
```
and one should be named similar to 
```
default-token-xxxxx
```
Copy that token name for use below.
Get the certificate by running this command:
```
kubectl get secret <secret name> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
```


####Service token
```
nano gitlab-admin-service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: gitlab-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: gitlab
    namespace: kube-system
```
```
kubectl apply -f gitlab-admin-service-account.yaml
#### get token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')

```
```
# Additional
## Working With Nodes and Clusters
```
Add Nodes
To add a new node, append the new node information to the cluster config file (config-sample.yaml) and then apply the changes using the following command.
./kk add nodes -f config-sample.yaml
```
Delete Nodes
To delete a node, use the below command, which should indicate the nodeName to be removed.
```
./kk delete node <nodeName> -f config-sample.yaml
```
# Delete Cluster
```
To delete a cluster, use one of the below commands. If you started with the quick start (all-in-one):

./kk delete cluster
If you started with the advanced (created with a configuration file):

./kk delete cluster [-f config-sample.yaml]
```
# Upgrade Cluster
There are two options here. 

We can use the All-in-one method to upgrade the cluster to a specific version. This approach supports upgrading Kubernetes, KubeSphere, or both Kubernetes and KubeSphere.
```
./kk upgrade [--with-kubernetes version] [--with-kubesphere version]  
```
2. Using the Multi-node process, we can upgrade the cluster using a specific configuration file.
```
./kk upgrade [--with-kubernetes version] [--with-kubesphere version] [(-f | --file) path] 
```
If running the commands using the –with-kubernetes or –with-kubesphere flags, the configuration file will also be amended. Alternatively, we can use the -f flag to specify which configuration file was built for the cluster creation.

Note:
When upgrading a multi-node cluster, we need to specify a configuration file. If a cluster is installed without using KubeKey, or the configuration file used for the installation is not found, a configuration file will need to be generated. This command obtains the cluster information and generates a KubeKey configuration file that can be used in the subsequent clusters.
```
./kk create config [--from-cluster] [(-f | --file) path] [--kubeconfig path]
```
Here we define the flags used above. 
```
–from-cluster: This flag indicates that we are retrieving the cluster’s information from an existing cluster.
-f: This flag refers to the path where the configuration file will be generated.
–kubeconfig: This flag refers to the path where kubeconfig is located.
Once the configuration file is generated, several parameters need to be added, like the ssh information for the nodes.
```


# KUBESPHERE
Make sure port 30880 is opened in your security group and access the web console through the NodePort (IP:30880) with the default account and password (admin/P@88w0rd).
admin/P@88w0rd
**http://172.1.1.1:30880/login**
