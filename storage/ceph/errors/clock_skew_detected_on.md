```
clock skew detected on mon.ceph02, mon.ceph03, mon.ceph05, mon.ceph04, mon.ceph07, mon.ceph06
go to server mon.ceph06

ceph -s
ceph health detail

HEALTH_WARN 5365 slow ops, oldest one blocked for 29235 sec, mon.ceph06 has slow ops; clock skew detected on mon.ceph02, mon.ceph03, mon.ceph05, mon.ceph04, mon.ceph07, mon.ceph06
SLOW_OPS 5365 slow ops, oldest one blocked for 29235 sec, mon.ceph06 has slow ops
MON_CLOCK_SKEW clock skew detected on mon.ceph02, mon.ceph03, mon.ceph05, mon.ceph04, mon.ceph07, mon.ceph06
    mon.ceph02 clock skew 21.7386s > max 0.05s (latency 0.000873144s)
    mon.ceph03 clock skew 21.8007s > max 0.05s (latency 0.000821936s)
    mon.ceph05 clock skew 21.407s > max 0.05s (latency 0.000895639s)
    mon.ceph04 clock skew 21.3146s > max 0.05s (latency 0.000847921s)
    mon.ceph07 clock skew 21.2449s > max 0.05s (latency 0.00142226s)
    mon.ceph06 clock skew 66.1015s > max 0.05s (latency 0.000900432s)

# solution
systemctl restart chronyd
ntpdate ru.pool.ntp.org



если упал s3 - не загружается список бакетов в s3 браузере
https://s3.company.ru/ тут пусто
перезагрузить ceph-rdgw сервер 10.3.3.104

# VM WARE - SERVER - EDIT SETTINGS - ADVANCED - VMWARE TOOLS / Time sync  disabled!!!

```
