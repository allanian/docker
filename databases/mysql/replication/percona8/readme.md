# REPLICATION
```
##########################
# ON MASTER
##########################
# install mysql, if need
# смотрим авто-пароль
grep -i password /var/log/mysqld.log
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
Exit;
mysql -u root -p'password'
SHOW MASTER STATUS\G
On master, create user
# create user - replica
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'password';
GRANT replication slave ON *.* TO 'repl_user'@'%';
FLUSH PRIVILEGES;
# check server-id
SELECT @@server_id;
```
# полный бэкап
xtrabackup --backup --user=root --password=password --target-dir=/data/bkp/
# подготовка для развертывания
xtrabackup --user=root --password=password --prepare --target-dir=/data/bkp/
xtrabackup --defaults-file="/etc/my.cnf.d/mysqld.conf" --move-back --target-dir=/data/bkp			 
# copy on slave server
rsync -avpPO -e ssh /data/bkp/ test@sql02:/data/bkp/
rsync -avpPO -e ssh /data/bkp/ test@sql03:/data/bkp/

##########################
# ON SLAVE's
##########################
# install percona xtrabackup 8
systemctl stop mysql
# clear old data_dir
mv /data_dir /old_data_dir 

# restore from backup dir
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
mysql -uroot -p'password'

# start slave
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST = 'sql01', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'mysql-bin.013849', MASTER_LOG_POS = 765893607;
START SLAVE;
SHOW SLAVE STATUS \G

Ошибок быть не должно и статус должен быть YES.
SQL YES
SQL YES


# on master don’t forget to create user
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'password';
GRANT replication slave ON *.* TO 'repl_user'@'%';
GRANT REPLICATION SLAVE ON *.*  TO 'repl'@'$slaveip' IDENTIFIED BY '$slavepass';
ALTER USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;


```
