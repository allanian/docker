DEL NODE
# out node
ceph osd out 7
ceph -w
ceph osd stop 7

#ceph auth del osd.7
#ceph osd rm 7


# list osd on node ceph07
ceph osd crush ls ceph07


Reduced data availability: 360 pgs inactive, 51 pgs down, 7 pgs stale


#  list pools
ceph osd lspools
ceph osd pool get data_hdd size
data_hdd - pool name
ceph osd pool get data_hdd pg_num
ceph osd pool get data_hdd pgp_num








ceph osd pool get data_hdd size
size: 2
сколько может не работать





# ERROR
5 osds down
# solution
ceph osd ls


ceph osd create 7
ceph auth add osd.7 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-7/keyring


ceph osd crush add {id-or-name} {weight}  [{bucket-type}={bucket-name} ...]




ceph osd crush osd.7 ls

# find osd with name osd.7
ceph osd find osd.7


# remove osd

# first - out it
#ceph osd out {osd-num}
ceph osd out osd.7

# после выключения ноды, ceph начнет перебалансировку, можно увидеть так
ceph -w


так же можно изменить вес ноды
ceph osd crush reweight osd.7 0


#  ОСТАНОВКА ЭКРАННОГО МЕНЮ
sudo systemctl stop ceph-osd@{osd-num}
Как только вы остановите свое экранное меню, оно будет down.

УДАЛЕНИЕ ЭКРАННОГО МЕНЮ

Эта процедура удаляет OSD из карты кластера, удаляет его ключ аутентификации, удаляет OSD из карты OSD и удаляет OSD из ceph.confфайла. Если у вашего хоста несколько дисков, вам может потребоваться удалить OSD для каждого диска, повторив эту процедуру.

Пусть кластер сначала забудет OSD. Этот шаг удаляет OSD из карты CRUSH, удаляет его ключ аутентификации. И он также удаляется с карты OSD. Обратите внимание, что подкоманда очистки введена в Luminous, для более старых версий см. Ниже.

ceph osd purge {id} --yes-i-really-mean-it











# OLD
systemctl start ceph-osd@7
systemctl status ceph-osd@7




/usr/lib/ceph/ceph-osd-prestart.sh --cluster ceph --id 7
/usr/bin/ceph-osd -f --cluster ${CLUSTER} --id %i --setuser ceph --setgroup ceph
/usr/bin/ceph-osd -f --cluster ceph --id 7 --setuser ceph --setgroup ceph
