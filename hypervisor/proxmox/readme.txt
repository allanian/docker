copy *ova to proxmox server
# Extract the contents of the OVA file. The content that we need here is the .ovf file.
tar xvf Bitrix.ova
#Bitrix.ovf
#Bitrix.mf
#Bitrix-disk1.vmdk
#Once the .ovf file has been extracted from the .ova file, we need to execute the qm command.
/usr/sbin/qm importovf 301 Bitrix.ovf local-lvm
301 - id
local-lvm - id storage


tar xvf Confluence.ova
/usr/sbin/qm importovf 302 Confluence.ovf local-lvm

tar xvf WEB_SERVER.ova
/usr/sbin/qm importovf 303 WEB_SERVER.ovf local-lvm

tar xvf redmine+openfire.ova
/usr/sbin/qm importovf 304 redmine+openfire.ovf local-lvm

tar xvf Gitlab_Runner.ova
/usr/sbin/qm importovf 313 Gitlab_Runner.ovf local-lvm

tar xvf GITLAB.ova
/usr/sbin/qm importovf 306 GITLAB.ovf local-lvm

заходим в хардваре
добавляем unused disk - type sata/ide и в options выбираем boot order
если нужно сного детачим диск и заного добавляем с нужным типом

# либо создаем виртуалку
удаляем диск
заливаем VMDK
/usr/sbin/qm importdisk 100 Bitrix-disk1.vmdk local-lvm -format qcow2
/usr/sbin/qm importdisk 305 Gitlab_Runner-disk2.vmdk local-lvm -format qcow2
Gitlab_Runner-disk2.vmdk
заходим в хардваре
добавляем unused disk - type sata/ide и в options выбираем boot order

работают оба способа




/usr/sbin/qm importdisk 300 Jira_0-flat.vmdk local-lvm -format qcow2

# windows proxmox 
use network INTEL

