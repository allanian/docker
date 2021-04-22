# MYSQL Percona 8

# Menu
 - [Backup](https://github.com/allanian/docker/tree/master/databases/mysql#BACKUP)
 - [Replication](https://github.com/allanian/docker/tree/master/databases/mysql#Replication)

# MYSQL Optimization
### 1. Example of query
|Query|Desc|
|--|--|
|set global max_connections = 2000;|set global param|
|show variables like 'binlog_format';| select param |

### 2. Slow query analyzator for percona
```
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
# enable percona repos
percona-release setup ps80 
# also enable AppSteam repo for rhel8
# install tools
yum install percona-toolkit
# run check
pt-query-digest /var/log/mysql/mysql-slow.log
```
### 3. OPTIMIZATION
```
# OPTIMIZATION
# check current
http://blog.itpub.net/29096438/viewspace-2665869/
# on master query it:
show global variables like '%group_commit%';
show variables like 'binlog_group_commit_sync_delay';

# указывает сколько максимально транзакций ждут отложенной отправки
set global binlog_group_commit_sync_no_delay_count=20;
# указывает сколько в Миллисекундах binlog ждать до синхронизации с диском (0 выключает).  Если время указанного выше параметра не истекло, но количество транзакций увеличилось, он будет напрямую синхронизирован с диском. Если он  binlog_group_commit_sync_delay не включен, этот параметр не будет включен.
set global binlog_group_commit_sync_delay=10;

# on slave enable this - паралельные потоки
slave-parallel-type=LOGICAL_CLOCK
slave-parallel-workers=20
# последовательное применение транзакций
slave_preserve_commit_order=ON
# check working on slaves
SELECT performance_schema.events_transactions_summary_by_thread_by_event_name.THREAD_ID AS THREAD_ID
, performance_schema.events_transactions_summary_by_thread_by_event_name.COUNT_STAR AS COUNT_STAR 
FROM performance_schema.events_transactions_summary_by_thread_by_event_name 
WHERE performance_schema.events_transactions_summary_by_thread_by_event_name.THREAD_ID IN 
     (SELECT performance_schema.replication_applier_status_by_worker.THREAD_ID 
      FROM performance_schema.replication_applier_status_by_worker);

Implement google BBR on binlog servers (blackhole engines)
Kernel version 4.19.12
nano /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
sysctl -p
For parallel slave replication
Upgrade master and slaves  to 5.7.22 or higher
Change the following parameters on the master/slave
slave_parallel_type=LOGICAL_CLOCK
binlog_format=’ROW’
transaction_write_set_extraction=’XXHASH64′
Slave_parallel_workers=8/16
binlog_transaction_dependency_tracking = WRITESET
Configure network recover parameters:
slave_net_timeout=60
MASTER_CONNECT_RETRY=60


```
.
# Master-Slave replication
## Install - Centos 8 Stream
```
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
# enable repo
sudo percona-release setup ps80
# disable mysql
sudo dnf module disable mysql
# install
sudo yum install percona-server-server percona-toolkit
sudo percona-release enable-only tools release
sudo yum install percona-xtrabackup-80
# start
mkdir -p /etc/systemd/system/mysqld.service.d/
nano /etc/systemd/system/mysqld.service.d/override.conf

[Service]
LimitNOFILE=999999

systemctl daemon-reload
systemctl restart mysqld
sudo systemctl enable --now mysqld
# get temp password
sudo grep "temporary password" /var/log/mysqld.log
mysql_secure_installation 
# access to db - sudo grep "temporary password" /var/log/mysqld.log
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
```
## Backup 
### FULL
```
xtrabackup --backup --user=root --password=pass --target-dir=/data/bkp/
####### подготовка для развертывания
xtrabackup --user=root --password=pass --prepare --target-dir=/data/bkp/
```



## Replication
### Master/Slave
#### Plan
```
# create user for replication
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'Ax1!SD@dd3s';
GRANT replication slave ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;
quit;
# full backup on master
xtrabackup --backup --user=root --password=pass --target-dir=/data/bkp/
####### подготовка для развертывания
xtrabackup --user=root --password=pass --prepare --target-dir=/data/bkp/
```
#### copy on servers (master/slave)
```
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql04:/data/bkp/
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql03:/data/bkp/
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql02:/data/bkp/
```
#### on master (if multi-master/transfer master)
 1. install percona xtrabackup 8
 2. restore from backup dir
```
yum install rsync -y
systemctl stop mysql
#mv old_data_dir
mv /home/mysql /home/mysql-old
my /home/mysql-logs /home/mysql-logs-old
mkdir -p /home/mysql
mkdir -p /home/mysql-logs
mkdir -p /var/log/mysql
# restore
xtrabackup --defaults-file="/etc/my.cnf" --move-back --target-dir=/data/bkp
# chown to mysql datadir
## chown -R mysql:mysql data_dir_mysql
chown -R mysql:mysql /home/mysql
chown -R mysql:mysql /home/mysql-logs
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/log/mysql
# copy config to /etc/my.cnf
systemctl restart mysqld
mysql -u root -p'PASS'
SHOW MASTER STATUS\G
mysql> SHOW MASTER STATUS\G
```
#### on slave
 1. install percona xtrabackup 8
 2. restore from backup dir
```
yum install rsync -y
xtrabackup --defaults-file="/etc/my.cnf" --move-back --target-dir=/data/bkp
# chown to mysql datadir
chown -R mysql:mysql /data/mysql
chown -R mysql:mysql /data/mysql-logs
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/log/mysql
# get current log file and pos – Позиции должны быть на момент создания бэкапа, иначе будут ошибки, можно посмотреть в файле или show master status;
cat /data/bkp/xtrabackup_binlog_info
mysql-bin.014649	156
# start db
systemctl start mysqld
# connect to db
mysql -uroot -p'pass'

# start slave
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST = 'rv-site-sql01', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.014649', MASTER_LOG_POS = 156;
START SLAVE;
SHOW SLAVE STATUS \G

Ошибок быть не должно и статус должен быть YES.
SQL YES
SQL YES
```

### ERROR
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
