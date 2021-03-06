# docker-compose.yml
```
version: "3.8"
services:
  clustercontrol:
    image: severalnines/clustercontrol:1.8.1-4
    container_name: clustercontrol
    environment:
      CMON_PASSWORD: DAakJ[t8-Zp=A3{&%K@CzgHY8&dH
      MYSQL_ROOT_PASSWORD: DAakJ[t8-Zp=A3{&%K@CzgHY8&dH
    volumes:
      - ./clustercontrol/cmon.d:/etc/cmon.d
      - ./clustercontrol/datadir:/var/lib/mysql
      - ./clustercontrol/sshkey:/root/.ssh:rw
      - ./clustercontrol/cmonlib:/var/lib/cmon
      - ./clustercontrol/backups:/root/backups
    ports:
      - 5000:80
      - 5001:443
    networks:
      - cluster-control

networks:
  cluster-control:
```
login to web app
http://10.3.3.211:5000/

# LDAP Configuration Settings
```
Go to User Management / Ldap Configuration
Add Teams:
Users: read
Admins: write

Map LDAP GROUP
TEAM - admins
LDAP Group - Domain Admin



Go to User Management / Ldap Settings / LDAP Configuration Settings
LDAP/LDAPS URI - ldap://rv-dc01.company.ru:389
Login DN - CN=clustercontrol,CN=Users,DC=rendez-vous,DC=ru
Login DN Password - QWE123qwe
User Base DN - dc=company,dc=ru   OU=ФОД_Отдел информационных технологий,OU=Департамент финансово-операционный,OU=..RENDEZVOUS,DC=rendez-vous,DC=ru
Group Base DN - dc=company,dc=ru


base dn - dc=company,dc=ru
login dn=cn=user,dc=company,dc=ru
password

#ROLE MAP
Team - Company
LDAP GROUP NAME - CN=Domain Admin,CN=Users - path without DC!
Role - super admin




######## IMPORT CLUSTER
### Create user in mysql DB
CREATE USER 'clustercontrol'@'%' IDENTIFIED WITH mysql_native_password BY 'QWE123qwe';
GRANT ALL ON *.* TO 'clustercontrol'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;



```
# SQL USER
```
CREATE USER 'clustercontrol'@'%' IDENTIFIED WITH mysql_native_password BY 'QWE123qwe';
GRANT ALL ON *.* TO 'clustercontrol'@'%' WITH GRANT OPTION;
CREATE USER 'clustercontrol'@'10.3.3.211' IDENTIFIED WITH mysql_native_password BY 'QWE123qwe!';
GRANT ALL ON *.* TO 'clustercontrol'@'10.3.3.211' WITH GRANT OPTION;
CREATE USER 'clustercontrol'@'10.3.3.231' IDENTIFIED WITH mysql_native_password BY 'QWE123qwe!';
GRANT ALL ON *.* TO 'clustercontrol'@'10.3.3.231' WITH GRANT OPTION;
FLUSH PRIVILEGES;
DROP USER IF EXISTS clustercontrol;
SELECT User FROM mysql.user where user='clustercontrol';

CREATE USER 'cmon'@'%' IDENTIFIED WITH mysql_native_password BY 'QWE123qwe!';
GRANT ALL PRIVILEGES ON *.* TO 'cmon'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

```
# CLI
```
s9s user --create \
    --group=admins \
    --generate-key \
    --controller=https://127.0.0.1:9501 \
    --new-password="QWE123qwe" \
    --email-address="46653@rendez-vous.ru" \
    admin
	
clustercontrol
# list of users
s9s user --list --long
# change password
s9s user --change-password --new-password=QWE123qwe admin

# ERRORS:
#User dba is suspended for previous authentication failures.
mv ~/.s9s/s9s.conf ~/.s9s/s9s.conf.bak
mv /etc/s9s.conf /etc/s9s.conf.bak
 
# create user dba in group admins
s9s user --create --generate-key --controller="https://localhost:9501" --group=admins dba
# unlock the suspended user - admin
s9s user --cmon-user=dba --enable admin



yum -y install mysql-server mysql php php-mysql php-gd mod_ssl php-curl php-ldap php-xml wget python3
ln -s /usr/bin/python3 /usr/bin/python
systemctl stop nginx
wget https://severalnines.com/downloads/cmon/install-cc
chmod 755 install-cc



sudo S9S_CMON_PASSWORD=QWE123qwe S9S_ROOT_PASSWORD=QWE123qwe S9S_DB_PORT=3306 HOST=10.3.3.211  ./install-cc


mysql password - QWE123qwe
CMON user password - QWE123qwe!
mysql_hostname=127.0.0.1
mysql_port=3306
mysql_password='QWE123qwe!'
cmon_user=cmon
cmon_db=cmon


yum install nginx php-fpm -y 
systemctl stop httpd
systemctl disable httpd

# uninstall
./install-cc --uninstall

```
