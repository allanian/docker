# k8s
# all namespaces
kubectl get ns
# more info about namespace
kubectl describe ns dsa
kubectl delete ns dsa
kubectl delete statefulsets dsatest
# show services
kubectl get services

# get all statefulsets in namespace DSA
kubectl -n dsa get statefulsets
kubectl -n dsa describe statefulsets

# delete statefulsets in namespace DSA
kubectl -n dsa delete statefulsets dsatest


###################
STATEFULSET



###################
DEPLOYMENT
#
kubectl -n dsa get deployments


statefulset
демплоймент запускает сразу все поды и контейнеры
деплоймент не дает разграничить, волум для всего, будет один волум для всех
statefulset запускает поды поочереди последовательно по порядку с 0 до 3,4....10
statefulset создает волум для каждого контейнера

ноде-селектор - указывает на каких нодах нужно запустить по метках
аффинити - описывает различные способы запускает
ноде-аффинити
- запускает на нодах где есть метка - МЕТКАИМЯ
- если не получается, на прошлое правило, можно запустить на других
- под-аффинити можно сказать чтобы поды всегда стояли на разных узлах с одной меткой (типо слэйвы бд на разных нодах)

ИНИТКОНТЕЙНЕРС
выполняет настройки перед запуском приложения, путем запуска доп. контейнера, который выполняет инструкции


можно использовать ДНС имя для обращения к кластеру БД
кластер.ИП: ноне


deployment for NGINX, FRONT,BACK - без генерации данных
statefulset для БД
