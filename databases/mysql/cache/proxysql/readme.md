doc proxysql
```
https://ip:6080/stats?metric=mysql
login/password
stats/stats
```


```
#proxysql connect 
# 6032 - admin
# 6033 - mysql
apt-get update && apt-get install mysql-client -y
mysql -uadmin -p'admin' -h 127.0.0.1 -P6032

# list servers
select hostgroup_id,hostname,port,status from runtime_mysql_servers;
SELECT * FROM global_variables where variable_name like 'admin-web%';

# proxysql current config
SELECT * FROM global_variables where variable_name like 'mysql-monitor%';


show status where `variable_name` = 'Threads_connected';

# MYSQL
mysql -uroot -p'rS4EKcUU50uXRQYe'
mysql -usammy -h127.0.0.1 -p -P6033 -e "SELECT @@HOSTNAME as hostname"

journalctl -u proxysql -f
tail -f /var/lib/proxysql/proxysql.log
```
