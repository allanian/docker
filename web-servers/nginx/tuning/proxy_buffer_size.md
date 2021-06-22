# Identify your header size
```
curl -s -w \%{size_header} -o /dev/null https://site.com
879
curl -s -w \%{size_header} -o /dev/null http://localhost -H "Host: site.com"
240

if we got 9000, we need increase proxy_buffer_size
on linux get page size:
getconf PAGESIZE
default - 4096
So aligning 9000 to 4k chunks, we get 12k:
proxy_buffer_size 12k;
```

```
#Disable Transparent HugePages in CentOS 8
cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
 
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo never > /sys/kernel/mm/transparent_hugepage/defrag
Add this command to /etc/rc.local to persis the configuration across reboots!
 
# reboot
# check thp
cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
```
