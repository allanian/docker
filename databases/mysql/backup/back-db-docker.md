```
BACKUP db in docker
Стандартные схемы – их бэкапить не надо
docker exec -it mysql mysql -u root -pdxBx6tpRTe
show databases;
information_schem
mysql
performance_schema
sys
#backup api
docker exec mysql /usr/bin/mysqldump -u root --password=dxBx6tpRTe api | gzip > /tmp/api.gz

```
