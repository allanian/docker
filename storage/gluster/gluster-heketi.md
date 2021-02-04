# GLUSTERFS INFO
BRICK - это ДИСК примантированный в папку
mkdir -p /data/brick1
mkdir -p /data/brick2
/dev/sdb /data/brick1
/dev/sdc /data/brick2

VOLUME 
это директория внутри бриков
/data/brick1/MYVOLUME
/data/brick1/MYVOLUME

# HEKETI
## INSTALLATION - all in ansible gluster role

## ADD new brick
in vmware, just add new disk, it's all, heketi do all job!


# Usage
nano ~/.bashrc
export HEKETI_CLI_SERVER=http://localhost:9888
export HEKETI_CLI_KEY=ivs4weORN7ERNeKVO
export HEKETI_CLI_USER=admin
source ~/.bashrc

heketi-cli --server http://localhost:9888 --user admin --secret ivs4weORN7ERNeKVO topology  load --json=/etc/heketi/topology.json
heketi-cli topology load --json=/etc/heketi/topology.json

heketi-cli topology info

# check
heketi-cli cluster list
heketi-cli node list
heketi-cli node info 0c349dcaec068d7a78334deaef5cbb9a

# NOW CREATE GLUSTER VOLUME
# create gluster volume with size 1GB
heketi-cli volume create --size=1
heketi-cli volume list
heketi-cli topology info
gluster pool list
gluster volume list


# HEKETI k8s
heketi-cli cluster list
# Get a base64 format of your Heketi admin user password.
echo -n "ivs4weORN7ERNeKVO" | base64
aXZzNHdlT1JON0VSTmVLVk8=

nano gluster-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: heketi-secret
  namespace: default
type: "kubernetes.io/glusterfs"
data:
  # echo -n "PASSWORD" | base64
  key: aXZzNHdlT1JON0VSTmVLVk8=

kubectl create -f gluster-secret.yaml
kubectl get secret


# storageCLASS
nano gluster-sc.yaml
 kind: StorageClass
 apiVersion: storage.k8s.io/v1
 metadata:
   name: gluster-heketi
 provisioner: kubernetes.io/glusterfs
 # delete volume auto, when a user deleted pvc
 reclaimPolicy: Delete
 # The Immediate mode indicates that volume binding and dynamic provisioning occurs once the PersistentVolumeClaim is created.
 volumeBindingMode: Immediate
 allowVolumeExpansion: true
 parameters:
   # The resturl is the URL of your heketi endpoint
   resturl: "http://gluster01:9888" 
   restuser: "admin" 
   secretName: "heketi-secret"
   secretNamespace: "default"
   # default replication factor
   volumetype: "replicate:2"
   volumenameprefix: "k8s-dev"
   clusterid: "b182cb76b881a0be2d44bd7f8fb07ea4"

kubectl create -f gluster-sc.yaml
kubectl get sc






# BACKUP
heketi-cli db dump > /opt/backup/heketi-db-dump-$(date -I).json





























# remove

heketi-cli node list
heketi-cli node disable 6c8bba2ca2f9561bafbfb8a63d64cdf6
heketi-cli node disable 6cb06e3e4bdee69a721130166849f2ce
heketi-cli node disable 7f184005f91df3efbafc72009a7b79ec
heketi-cli node delete 6c8bba2ca2f9561bafbfb8a63d64cdf6
heketi-cli node delete 6cb06e3e4bdee69a721130166849f2ce
heketi-cli node delete 7f184005f91df3efbafc72009a7b79ec

heketi-cli cluster delete 85e07224d8d79c9364b241a9e2921be4


проблема в том что topology load - не работает с существующим PV volume


# heketi + просто пустой диск без манипуляций внешних



# DELETE
lvdisplay 
umount /dev/data/lv_data
# disable volume
lvchange -an -v /dev/data/lv_data
# remove volume
lvremove /dev/data/lv_data

vgdisplay
vgremove data

pvdisplay
pvremove /dev/sdb









