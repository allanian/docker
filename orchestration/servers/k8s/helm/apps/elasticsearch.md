```
helm repo add elastic https://helm.elastic.co
get values.yaml for here for 6.8.14
https://github.com/elastic/helm-charts/blob/v6.8.16/elasticsearch/values.yaml
kubectl create ns smartsearch-es
helm delete smartsearch-es -n smartsearch-es
helm install smartsearch-es --values values.yaml -n smartsearch-es elastic/elasticsearch --version 6.8.16


1. Watch all cluster members come up.
  $ kubectl get pods --namespace=smartsearch-es -l app=elasticsearch-master -w
2. Test cluster health using Helm test.

helm install dsa-es elastic/elasticsearch --set volumeClaimTemplate.resources.requests.storage=10Gi --version 7.13.2

volumeClaimTemplate:
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 30Gi
```
