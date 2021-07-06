```
# PMM
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo yum install pmm2-client
sudo pmm-admin config --server-insecure-tls --server-url=https://admin:QWE123qwe@10.3.3.211:6001 --force
# MONITORING MYSQL 8
mysql
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY 'QWE123qwe' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'127.0.0.1';
ALTER USER 'pmm'@'127.0.0.1' IDENTIFIED BY 'QWE123qwe';

sudo  pmm-admin add mysql --username=pmm --password=QWE123qwe --query-source=perfschemaperfschema
```
