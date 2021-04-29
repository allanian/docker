# install
```
helm repo add couchbase https://couchbase-partners.github.io/helm-charts/
helm repo update
edit values.yaml
helm upgrade --install couchbase --values values.yaml couchbase/couchbase-operator
```
# uninstall
```
helm delete couchbase -n couchbase
```
# dont worked
```
Readiness probe failed: dial tcp 10.0.2.172:8091: connect: connection refused
[root@li77-19 couchbase]# kubectl -n couchbase get pods
NAME                                                       READY   STATUS    RESTARTS   AGE
cbdb-dev-0000                                              0/1     Running   0          3m39s
couchbase-couchbase-admission-controller-cc75ccfd7-8vwxd   1/1     Running   0          19h
couchbase-couchbase-operator-6c8f6d9579-g6pfq              1/1     Running   0          19h

kubectl -n couchbase logs -f --tail 20 couchbase-couchbase-operator-6c8f6d9579-g6pfq 
```
