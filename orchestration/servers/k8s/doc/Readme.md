## Переадресация портов
```
kubectl port-forward wordpress-tlr8l 8080:80 --address 0.0.0.0
```
# TAINT
```
we have node with name - powerbi-clickhouse.rendez-vous.ru
# TAINT ON HER
kubectl taint node powerbi-clickhouse.rendez-vous.ru node-role/clickhouse="":NoExecute
# list taint
kubectl describe node | egrep -i taint
```
## label
```
# show labels
kubectl get nodes --show-labels

# add label from node
kubectl label node <node name> node-role.kubernetes.io/<role name>=<key - (any name)>
kubectl label nodes <node name> clickhouse=true
kubectl label node <node name> node-role.kubernetes.io/worker= --overwrite

# delete label from node
kubectl label node <node name> node-role.kubernetes.io/<role name>-
kubectl label node <nodename> <labelname>-
```
## affinity
```
affinity - описывает различные способы запускает
node-affinity:
- запускает на нодах где есть метка - МЕТКА-ИМЯ
- если не получается, на прошлое правило, можно запустить на других
pod-affinity:
 поды всегда стояли на разных узлах с одной меткой (типо слэйвы бд на разных нодах)

initcontainers:
выполняет настройки перед запуском приложения, путем запуска доп. контейнера, который выполняет инструкции


можно использовать ДНС имя для обращения к кластеру БД
clusterIP: none
```
