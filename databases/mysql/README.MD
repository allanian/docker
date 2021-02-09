# MYSQL Percona 8

# Menu
 - [Backup](https://github.com/allanian/docker/tree/master/databases/mysql#BACKUP)
 - [Replication](https://github.com/allanian/docker/tree/master/databases/mysql#Replication)

# Install
## Centos 8 Stream
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
# Backup 
### FULL
```
xtrabackup --backup --user=root --password=pass --target-dir=/data/bkp/
####### подготовка для развертывания
xtrabackup --user=root --password=pass --prepare --target-dir=/data/bkp/
```



# Replication
## Master/Slave
### full backup on master
```
xtrabackup --backup --user=root --password=pass --target-dir=/data/bkp/
####### подготовка для развертывания
xtrabackup --user=root --password=pass --prepare --target-dir=/data/bkp/
```
### copy on servers (master/slave)
```
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql04:/data/bkp/
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql03:/data/bkp/
rsync -avpPO -e ssh /data/bkp/ test@rv-site-sql02:/data/bkp/
```
### on master (if multi-master/transfer master)
 1. install percona xtrabackup 8
 2. restore from backup dir
```
systemctl stop mysql
mv old_data_dir
xtrabackup --defaults-file="/etc/my.cnf.d/mysqld.conf" --move-back --target-dir=/data/bkp
# chown to mysql datadir
## chown -R mysql:mysql data_dir_mysql
chown -R mysql:mysql /home/mysql
chown -R mysql:mysql /var/lib/mysql
systemctl restart mysqld
mysql -u root -p'PASS'
SHOW MASTER STATUS\G
mysql> SHOW MASTER STATUS\G
```
### on slave
 1. install percona xtrabackup 8
 2. restore from backup dir
```
xtrabackup --move-back --target-dir=/data/bkp
# chown to mysql datadir
chown -R mysql:mysql /data/mysql
chown -R mysql:mysql /var/lib/mysql
# get current log file and pos – Позиции должны быть на момент создания бэкапа, иначе будут ошибки
#cat /var/lib/mysql/xtrabackup_binlog_pos_innodb
cat /data/bkp/xtrabackup_binlog_info
mysql-bin.013849	765893607
# start db
systemctl start mysqld
# connect to db
mysql -uroot -p'pass'

# start slave
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST = 'rv-site-sql01', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'Ax1!SD@dd3s', MASTER_LOG_FILE = 'mysql-bin.013849', MASTER_LOG_POS = 765893607;
START SLAVE;
SHOW SLAVE STATUS \G

Ошибок быть не должно и статус должен быть YES.
SQL YES
SQL YES
```

# ERROR
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
