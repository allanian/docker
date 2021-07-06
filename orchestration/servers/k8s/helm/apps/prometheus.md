
# Using
```
kubectl port-forward -n monitoring pod/prometheus-prometheus-kube-prometheus-prometheus-0 9090:9090 --address 0.0.0.0

#### ERROR
0/3 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate
kubectl taint nodes node1 node-role.kubernetes.io/master-

You can add Prometheus annotations to the metrics service using controller.metrics.service.annotations. 
Alternatively, if you use the Prometheus Operator, you can enable ServiceMonitor creation using controller.metrics.serviceMonitor.enabled.

kubectl annotate pods nginx-ingress-controller-pod prometheus.io/scrape=true -n ingress-nginx --overwrite
kubectl annotate pods nginx-ingress-controller-pod prometheus.io/port=10254  -n ingress-nginx --overwrite
```
# Install
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns monitoring

helm upgrade --install prometheus -n monitoring --values values.yaml prometheus-community/kube-prometheus-stack

# on k8s-ops06 node
mkdir /data/prometheus
kubectl apply -f pv.yml -n monitoring
apiVersion: v1
kind: PersistentVolume
metadata:
  name: prometheus-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/prometheus
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8s-ops06

```
