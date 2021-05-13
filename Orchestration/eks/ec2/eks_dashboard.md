
# k8s dashboard
```
# for delete
    kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
# for install
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
```
#### Создаем ServiceAccount для кластера:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: eks-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EOF
```
#### Создаем ServiceAccount для входа в борду:
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
```
# INGRESS HELM
```
cd dashboard
# dev
helm upgrade --install -f ./dashboard/values_qa.yaml -n kubernetes-dashboard dashboard dashboard/
# qa
helm upgrade --install -f ./dashboard/values_qa.yaml -n kubernetes-dashboard dashboard dashboard/

# token TTL
kubectl edit deployment kubernetes-dashboard -n kubernetes-dashboard
- '--token-ttl=0'
```

#### verify
```
# change ClusterIP to type: NodePort
export EDITOR=nano
kubectl edit svc -n kubernetes-dashboard
kubectl -n kubernetes-dashboard get pods
kubectl get deployment metrics-server -n kube-system
yum install jq -y
aws eks get-token --cluster-name $cluster_name | jq -r '.status.token'
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```
