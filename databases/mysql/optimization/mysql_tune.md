```
# MYSQL LINUX TUNING


0 
nano /etc/security/limits.conf
#[domain]      [type]  [item]         [value]
mysql hard nofile 102400
mysql soft nofile 102400

nano /etc/systemd/system/mysql.service
# Sets open_files_limit
LimitNOFILE = 102400
systemctl daemon-reload
systemctl restart mysql

cat /etc/my.cnf | grep open_files_limit
nano /etc/my.cnf

1 swapiness
nano /etc/sysctl.conf
#==========================================
# system
#===========================================
vm.swappiness=1
vm.max_map_count=262144
fs.file-max = 500000
# cache for 50gb RAM+, only 15%, default 40 and 10 for second param
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
#==========================================
# network
#===========================================
#net.core.default_qdisc = fq
#net.ipv4.tcp_congestion_control = bb
net.ipv4.ip_nonlocal_bind=1
net.ipv4.tcp_max_syn_backlog=4096
# Maximum length of each connection
net.core.somaxconn = 65535
# Optimize the system resources occupied by tcp failed links to speed up the resource recovery efficiency
net.ipv4.tcp_keepalive_time = 120    # Link validity time, default 7200
net.ipv4.tcp_keepalive_intvl = 30    # tcp The retransmission interval is not obtained, default 75
net.ipv4.tcp_keepalive_probes = 3    # Number of retransmissions, default 9
## Decrease the time default value for tcp_fin_timeout connection, default 60
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1


2 I/O Scheduler centos 8
cat /sys/block/nvme0n1/queue/scheduler
High-performance SSD or a CPU-bound system with fast storage
Use none, especially when running enterprise applications. Alternatively, use kyber.

3 CPU Governor
cpupower frequency-info

# driver: intel_pstate
# available cpufreq governors: performance powersave
# The governor "performance" may decide which speed to use within this range

# Вы также можете проверить настройку регулятора, выполнив следующую команду:
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

Если «performance» - вариант, вы можете внести изменения, введя команду:

echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor


4 NUMA
numactl --hardware


5 Filesystems – XFS
```
