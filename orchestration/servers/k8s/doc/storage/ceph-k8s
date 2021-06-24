# CEPH OSD
Устройство хранения объектов Ceph (OSD)

# CEPH POOLS
# list
ceph osd pool ls
# add new pool (name of pull and PG - default 8, but better got to 32 or 64) Total PGs = (Total_number_of_OSD * 100) / max_replication_count
ceph osd pool create kube 64
# delete pool (need to allow delete first, then delete, then disable allow to delete)
ceph tell mon.* injectargs --mon_allow_pool_delete true
ceph osd pool delete kube kube --yes-i-really-really-mean-it
ceph tell mon.* injectargs --mon_allow_pool_delete false

data_hdd - общий




# k8s CEPH
# on ceph server
# add new pull KUBE
ceph osd pool create kube 64
ceph osd pool application enable kube rbd

# on k8s server
helm repo add ceph-csi https://ceph.github.io/csi-charts
helm inspect values ceph-csi/ceph-csi-rbd > cephrbd.yml

# on ceph server
Теперь нужно заполнить файл cephrbd.yml. Для этого узнаем ID кластера и IP-адреса мониторов в Ceph:
ceph fsid  # так мы узнаем clusterID
ceph mon dump  # а так увидим IP-адреса мониторов

# on k8s server
Полученные значения заносим в файл cephrbd.yml. Попутно включаем создание политик PSP (Pod Security Policies).
# install to k8s
helm upgrade -i ceph-csi-rbd ceph-csi/ceph-csi-rbd -f cephrbd.yml -n ceph-csi-rbd --create-namespace

# on ceph server
Создаём нового пользователя в Ceph и выдаём ему права на запись в пул kube:
ceph auth get-or-create client.rbdkube mon 'profile rbd' osd 'profile rbd pool=kube'
А теперь посмотрим ключ доступа всё там же:
ceph auth get-key client.rbdkube
Команда выдаст нечто подобное:
AQBAJQBget0OARAAbktImcMm3NOf+8hO3lY0WQ==

# on k8s server
---
apiVersion: v1
kind: Secret
metadata:
  name: csi-rbd-secret
  namespace: ceph-csi-rbd
stringData:
  # Значения ключей соответствуют имени пользователя и его ключу, как указано в
  # кластере Ceph. ID юзера должен иметь доступ к пулу,
  # указанному в storage class
  userID: rbdkube
  userKey: AQBAJQBget0OARAAbktImcMm3NOf+8hO3lY0WQ==
  
kubectl apply -f secret.yml


Далее нам нужен примерно такой манифест StorageClass: id on ceph - ceph fsid
storageclass.yml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: csi-rbd-sc
provisioner: rbd.csi.ceph.com
parameters:
   clusterID: 28c11745-7865-45c6-858c-9fd4ba2d9cca
   pool: kube

   imageFeatures: layering

   # Эти секреты должны содержать данные для авторизации
   # в ваш пул.
   csi.storage.k8s.io/provisioner-secret-name: csi-rbd-secret
   csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi-rbd
   csi.storage.k8s.io/controller-expand-secret-name: csi-rbd-secret
   csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi-rbd
   csi.storage.k8s.io/node-stage-secret-name: csi-rbd-secret
   csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi-rbd

   csi.storage.k8s.io/fstype: ext4

reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - discard


kubectl apply -f storageclass.yml


# CHECK WORKING
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-rbd-sc

kubectl apply -f testpv.yml

Сразу посмотрим, как Kubernetes создал в Ceph запрошенный том:
kubectl get pvc
kubectl get pv

# ON CEPH server
Вроде бы всё отлично! А как это выглядит на стороне Ceph?
Получаем список томов в пуле и просматриваем информацию о нашем томе:
rbd ls -p kube
rbd -p kube info csi-vol-be66a5b6-570a-11eb-ba85-928bccafbd99  # тут, конечно же, будет другой ID тома, который выдала предыдущая команда

# on k8s 
change size storage and reapply
kubectl apply -f testpvc.yml
# on ceph server - should change size to 2GB
rbd -p kube info csi-vol-be66a5b6-570a-11eb-ba85-928bccafbd99
# on k8s
kubectl get pvc
kubectl get pv


kubectl get pv
kubectl get pvc

Видим, что размер у PVC не изменился. Чтобы узнать причину, можно запросить у Kubernetes описание PVC в формате YAML:
kubectl get pvc rbd-pvc -o yaml

А вот и проблема:
message: Waiting for user to (re-)start a pod to finish file system resize of volume on node. type: FileSystemResizePending
То есть диск увеличился, а файловая система на нём — нет.
Чтобы увеличить файловую систему, надо смонтировать том. У нас же созданный PVC/PV сейчас никак не используется.

nano testpod.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: csi-rbd-demo-pod
spec:
  containers:
    - name: web-server
      image: nginx:1.17.6
      volumeMounts:
        - name: mypvc
          mountPath: /data
  volumes:
    - name: mypvc
      persistentVolumeClaim:
        claimName: rbd-pvc
        readOnly: false
	
kubectl apply -f testpod.yml
Размер изменился, всё в порядке.
В первой части мы работали с блочным устройством RBD (оно так и расшифровывается – Rados Block Device), но так нельзя делать, если требуется одновременная работа с этим диском разных микросервисов. Для работы с файлами, а не с образом диска, намного лучше подходит CephFS.
На примере кластеров Ceph и Kubernetes настроим CSI и остальные необходимые сущности для работы с CephFS.

В первой части мы работали с блочным устройством RBD (оно так и расшифровывается – Rados Block Device), 
но так нельзя делать, если требуется одновременная работа с этим диском разных микросервисов. Для работы с файлами, а не с образом диска, намного лучше подходит CephFS.


!!!!!!!!!!!!!!!!!!!!!!! 2 часть
helm inspect values ceph-csi/ceph-csi-cephfs > cephfs.yml
ceph fsid
ceph mon dump
nano cephfs.yml
csiConfig:
  - clusterID: "28c11745-7865-45c6-858c-9fd4ba2d9cca"
    monitors:
      - "10.3.3.105:6789"
      - "10.3.3.106:6789"
      - "10.3.3.107:6789"
      - "10.3.3.110:6789"
      - "10.3.3.109:6789"
      - "10.3.3.119:6789"
      - "10.3.3.111:6789"
	  
  podSecurityPolicy:
    enabled: true 

  podSecurityPolicy:
    enabled: true 

Обратите внимание, что адреса мониторов указываются в простой форме address:port. Для монтирования cephfs на узле эти адреса передаются в модуль ядра, который ещё не умеет работать с протоколом мониторов v2.

helm upgrade -i ceph-csi-cephfs ceph-csi/ceph-csi-cephfs -f cephfs.yml -n ceph-csi-cephfs --create-namespace

# on ceph create user
ceph auth get-or-create client.fs mon 'allow r' mgr 'allow rw' mds 'allow rws' osd 'allow rw pool=cephfs_data, allow rw pool=cephfs_metadata'
ceph auth get-key client.fs
AQDFUwFgBNsvFRAAzOlC5gK4oX8odo7wkRLTXQ==

nano secretfs.yml
kubectl apply -f secretfs.yml
---
apiVersion: v1
kind: Secret
metadata:
  name: csi-cephfs-secret
  namespace: ceph-csi-cephfs
stringData:
  # Необходимо для динамически создаваемых томов
  adminID: fs
  adminKey: AQDFUwFgBNsvFRAAzOlC5gK4oX8odo7wkRLTXQ==


storageclassfs.yml
kubectl apply -f storageclassfs.yml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-cephfs-sc
provisioner: cephfs.csi.ceph.com
parameters:
  # ceph fsid
  clusterID: 28c11745-7865-45c6-858c-9fd4ba2d9cca

  # Имя файловой системы CephFS, в которой будет создан том
  fsName: cephfs

  # (необязательно) Пул Ceph, в котором будут храниться данные тома
  # pool: cephfs_data

  # (необязательно) Разделенные запятыми опции монтирования для Ceph-fuse
  # например:
  # fuseMountOptions: debug

  # (необязательно) Разделенные запятыми опции монтирования CephFS для ядра
  # См. man mount.ceph чтобы узнать список этих опций. Например:
  # kernelMountOptions: readdir_max_bytes=1048576,norbytes

  # Секреты должны содержать доступы для админа и/или юзера Ceph.
  csi.storage.k8s.io/provisioner-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/provisioner-secret-namespace: ceph-csi-cephfs
  csi.storage.k8s.io/controller-expand-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: ceph-csi-cephfs
  csi.storage.k8s.io/node-stage-secret-name: csi-cephfs-secret
  csi.storage.k8s.io/node-stage-secret-namespace: ceph-csi-cephfs

  # (необязательно) Драйвер может использовать либо ceph-fuse (fuse), 
  # либо ceph kernelclient (kernel).
  # Если не указано, будет использоваться монтирование томов по умолчанию,
  # это определяется поиском ceph-fuse и mount.ceph
  # mounter: kernel
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - debug

# check  create pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-cephfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: csi-cephfs-sc

kubectl apply -f testpvcfs.yml

kubectl get pvc
kubectl get pv

