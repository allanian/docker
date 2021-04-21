```
# use r5.large for start and increase it, use only memory optimized servers!
dnf update -y
 
nano /etc/sysctl.conf
# NETWORK AND MEMORY
# ===========================================
# Networking
# ===========================================
# Decrease the time default value for connections to keep-alive
net.ipv4.tcp_keepalive_time = 30
 
# Increase the frequence of keep-alive probes, identifying and timing out dead connections faster
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recylce = 1
 
# Enables reuse of TIME-WAIT sockets to reduce the time spent constructing connections.
# This setting is safe for all Couchbase protocols
# Warning!!!: net.ipv4.tcp_tw_recylce has been removed from Linux 4.1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recylce = 1
 
# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 14400000
# =====================================================
# MEMORY
# ==================================================
# instruct the kernel to swap only as a last resort
vm.swappiness = 1
# By default, the kernel platforms heuristic memory overcommit handling by estimating the amount of memory available and failing request that are too large.
# However, sinse memory allocated using heuristic rather than a precise algorithm, overloading memory is possible with this setting.
vm.overcommit_memory = 0
# Specifies the minimum number of kilobytes to keep free across the system. This is used to determine an appropriate value for each low memory zone.
vm.min_free_kbytes = 524288
 
# Limits the maximum memory used to 2GB befo pdflush is involved.
# The default 20% of total system memory can overwhelm the storage system once flushed. On lower memory systems use 512MB or 1GB
vm.dirty_bytes = 2147483648
 
# Contains the amount of dirty memory at which the background kernel flushed threads will start writeback. Limits the maximum memory used
# to 1GB before pdflush in involved
vm.dirty_background_bytes = 1073741824
 
# Increases the rate at which data is flushed to disk. This is particularly beneficial for SAN and EBS storage.
#vm.dirty_expire_centisecs = 300
#vm.dirty_writeback_centisecs = 100
 
# Increase size of file handles and inode cache
fs.file-max = 2097152
 
# Disables NUMA zone relcaim algorithm. This tends to decrease read latencies.
vm.zone_reclaim_mode = 0
 
sysctl -p
 
# FILESYSTEM MOUNTING
# Couchbase is not reliant on file access times, enabling noatime is safe and will decrease disk IO.
USE XFS
nano /etc/fstab
add rw,noatime
 
# OTHER OPTIMIZATION
# change scheduler
# default linux scheduler is cfq and is not well for database access patterns. deadline is more appropriate scheduler and provides better latency guarantees. Do that for all mountend volumes
sudo echo deadline > /sys/block/sda/queue/scheduler
# increase nr_requests
# default queue size for nr_requests is 128. This is number of read and write requests that can be queued before the next processing the request a read or write is put to sleep. Increasing the queue sizes reduces disk seeks by improving the write ordering.
sudo echo 1024 > /sys/block/sda/queue/nr_requests
# Decrease read_expire
# is the number of milliseconds in which a read request shoud be server. The default value is 500 and is relatively high, this value can be #lowered to 100
sudo echo 100 > /sys/block/sda/queue/iosched/read_expire
# Adjust writed_starved
# number of read batches to process before processing a single write batch. default is 2.
sudo echo 4 > /sys/block/sda/queue/iosched/writed_starved
# Disable rotational
# for SSD disks, rotational should be 0, to disable unneeded scheduler logic meant to reduce the number of seeks.
sudo echo 0 > /sys/block/sda/queue/rotational
# disable add_random
# by default ssd/hdd contribute entrypy to the kernel random number pool, for ssd disable it.
sudo ech0 > /sys/block/sda/queue/add_random
# increase rq_affinity
# improve cpu perfomance - good for 16cpu cores or more.
sud echo 2 > /sys/block/sda/queue/rv_affinity
 
# User Limits
nano /etc/security/limits.d/couchbase.conf
couchbase      soft    nofile          70000
couchbase      hard    nofile          70000
couchbase      hard    core            unlimited
reboot
 
 
 
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
 
# For ENTERPRISE
dnf install -y https://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-x86_64.rpm
dnf makecache
dnf install -y couchbase-server
 
# Firewalld
firewall-cmd --permanent --add-port={8091-8096,9140,11210,11211,11207,18091-18096,21100}/tcp
firewall-cmd --reload
 
systemctl status couchbase-server
 
ulimit -n 40960
ulimit -c unlimited
```
