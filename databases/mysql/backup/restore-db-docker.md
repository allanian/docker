```
Restore DB in docker
pv - its a tool for time-restore-show
# RESTORE MYSQL DB in docker
docker exec -i CONTAINER_ID mysql --user root --password=rS4EKcUU50uXRQYe DB_NAME < mysql/washhouse.sql.dump
docker exec -i sundeev-database mysql --user root --password=rS4EKcUU50uXRQYe rendez_vous < mysql/washhouse.sql.dump
# restore in docker with status
docker exec -it --user root database bash
yum install epel-release -y
yum install pv -y
# прокидываем волум к бэкапом в контейнер, или копируем бэкап в контейнер
# Restore
docker exec -it sundeev-database bash
pv /mysqlbkp/washhouse.sql.dump | /usr/bin/mysql --user root --password=rS4EKcUU50uXRQYe company
# restore in docker, need to test
docker exec -i sundeev-database /bin/bash -c "pv /mysqlbkp/washhouse.sql.dump | /usr/bin/mysql --user root --password=rS4EKcUU50uXRQYe company"

```
# examples
```
pv -pert /data/all.sql | mysql --user root --password='Ex1!SDdd3s' company
mysql -u root -p'Ex1!SDdd3s' < /data/all.sql
mysql -u root -p'Ex1!SDdd3s' sbtest < /data/company.bak
mysqlcheck -uroot -p'Ex1!SDdd3s' --all-databases --check-upgrade
```
