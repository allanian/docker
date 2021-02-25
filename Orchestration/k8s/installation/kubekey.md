# KUBEKEY
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
