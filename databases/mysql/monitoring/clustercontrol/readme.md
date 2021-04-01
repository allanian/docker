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

# LDAP
```
LDAP - ip
port - 389
base dn - dc=company,dc=ru
login dn=cn=user,dc=company,dc=ru
password

#ROLE MAP
Team - Company
LDAP GROUP NAME - CN=Domain Admin,CN=Users - path without DC!
Role - super admin
```
