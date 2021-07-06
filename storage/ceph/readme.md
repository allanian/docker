# Ceph
```
# CEPH HEALTH STATUS ERROR IN GRAFANA
[root@ceph01 ~]# ceph health detail
HEALTH_ERR 1 full osd(s); 10 pool(s) full
OSD_FULL 1 full osd(s)
    osd.2 is full



ceph osd df
Общую заполненность кластера / пула можно проверить с помощью

ceph df
Обратите особое внимание на самые полные OSD, а не на процент использования необработанного пространства, как сообщает . Достаточно заполнить только одно выпадающее OSD, чтобы запись в его пул закончилась неудачей.\

Ceph требуется свободное дисковое пространство для перемещения блоков хранения, называемых pg s, между разными дисками. Поскольку это свободное пространство настолько критично для базовой функциональности, Ceph войдет в него, HEALTH_WARNкогда любое OSD достигнет near_fullсоотношения (обычно 85% заполнено), и остановит операции записи в кластере, войдя в HEALTH_ERRсостояние, как только OSD достигнет full_ratio.

Однако, если ваш кластер не идеально сбалансирован для всех OSD, вероятно, будет гораздо больше доступной емкости, поскольку OSD обычно используются неравномерно. Чтобы проверить общее использование и доступную мощность, вы можете запустить ceph osd df.


ceph osd reweight-by-utilization
Это можно сделать вручную, перенастроив OSD, или вы можете сделать так, чтобы Ceph произвел оптимальную перебалансировку, запустив команду ceph osd reweight-by-utilization. 
Как только перебалансировка завершена (т. Е. У вас нет потерянных объектов ceph status), 
вы можете снова проверить вариацию (используя ceph osd df) и при необходимости запустить другую перебалансировку.


ceph osd df
смотрим на столбик 
 REWEIGHT
 
это вес
если его уменьшить, будет ребалансировка


list pools
ceph osd lspools


# REDUCE POOL REPLICAS
default 3, minimum 2, so we set minimum and current to 2
ceph osd pool set data_hdd size 2

```
## status
ceph -s
ceph health detail
Команды диагностики:
ceph status
ceph osd status
ceph osd df
ceph osd utilization
ceph osd pool stats
ceph osd tree
ceph pg stat

## Users
radosgw-admin user list
radosgw-admin user create --uid=test1 --display-name="Test1" --email=test1@test.ru



## DEL NODE
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
