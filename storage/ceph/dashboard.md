
# Update dashboard SSL
```
# ssl for dashboard - copy certs
connect to any node CEPH
mkdir -p /etc/ssl/rv-ssl/new_certs && cd /etc/ssl/rv-ssl/new_certs
ceph dashboard set-ssl-certificate -i rendez-vous.cer
ceph dashboard set-ssl-certificate-key -i rendez-vous.key

# restart dashboard
ceph mgr module disable dashboard
ceph mgr module enable dashboard
```

# Grafana Ceph ssl
```

CEPH  Grafana SSL
go to grafana server
cd /etc/grafana/
cat grafana.ini
check cert path
update it
restart grafana-service

```
