```
PVC IN ESXI
0) In esxi console go to Administation menu / Single Sign On / Users and group
Domain vcd.local
k8s-ops-cluster
1) Login to K8s dashboard go to Cluster/Persistent Volumes/ select existing and click edit / find volumePath
example - "volumePath": "[HP_SAN01_LUN01_HDD] k8s-ops-volumes/onecjenkins.vmdk",
2) Go to ESXI console https://vcd-vcsa.company.ru / HOST and Clusters / VCD-CLUSTER-HP (it’s old cluster, better use vcd-cluster!)
Select server (example, vcd-esxi07.rendez-vous.ru)
Go to Tab Configure / System / Services
Find SSH in Table and click RUN
3) Connect with SSH to  root@vcd-esxi07.rendez-vous.ru
Вбиваем VCD-ESXI
4) Create volume
vmkfstools -c 2G /vmfs/volumes/HP_SAN01_LUN01_HDD/k8s-ops-volumes/mspa_db.vmdk
ls -la /vmfs/volumes/HP_SAN01_LUN01_HDD/k8s-ops-volumes/
1)	create Persistent Volume (монтирование волума к K8s)
	capacity: размер диска
	accessModes: типа доступа, тут ReadWriteOnce — раздел может быть смонтирован только к одной рабочей ноде с правами чтения/записи
	storageClassName: тип хранилища, см. ниже
	awsElasticBlockStore: тип используемого диска
	fsType: тип файловой системы

Параметр storageClassName определяет тип хранилища.
И для PVC, и для PV должен быть задан один и тот же класс, иначе PVC не подключит PV, и STATUS такого PVC будет Pending.
#get storageClass
kubectl get storageclass
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-mspa-db
  namespace: mspa-134-default
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  persistentVolumeReclaimPolicy: Retain
  vsphereVolume:
    volumePath: "[HP_SAN01_LUN01_HDD] k8s-ops-volumes/mspa_db.vmdk"
    fsType: ext4

[HP_SAN01_LUN01_HDD] – имя датастора
Create Persistent Volume CLAIM (запрос на использование волума)
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-mspa-db
  namespace: mspa-134-default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
      
kubectl describe pvc 
[root@k8s-ops01 pv-test]# kubectl describe pvc mspa-db -n mspa-134-default
Name:          mspa-db
Namespace:     mspa-134-default
StorageClass:  
Status:        Bound
Volume:        mspa-db
```
