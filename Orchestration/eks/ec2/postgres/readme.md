```

helm upgrade --install \
 -n postgres postgres-cms bitnami/postgresql \
 --set postgresqlPassword=123,postgresqlDatabase=dbname \
 --set persistence.storageClass=ebs-sc --set persistence.accessMode=ReadWriteMany --set persistence.size=8Gi

```
