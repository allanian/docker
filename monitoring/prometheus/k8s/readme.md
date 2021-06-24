# on k8s-ops06 node
mkdir /data/prometheus
kubectl apply -f pv.yml -n monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns monitoring
helm upgrade --install prometheus -n monitoring --values values.yaml prometheus-community/kube-prometheus-stack
