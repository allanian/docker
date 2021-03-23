# Memcached
```
# install centos8
enable AppStream repo
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --set-enabled powertools

sudo dnf install memcached libmemcached
nano /etc/sysconfig/memcached
PORT="11211"
USER="memcached"
MAXCONN="50000"
CACHESIZE="1024"
#LOGFILE="/var/log/memcached2.log" # dont worked, memcashed dont connect to app
OPTIONS="-v -t 4"

sudo systemctl enable memcached --now
sudo systemctl status memcached

# how check from app
<?php
$memcached = new Memcached();
$memcached->addServer('10.10.10.5', 11211);

$name = 'testkey';
$ttl = 10;
$data = "It works! )";

$memcached->set($name, $data, $ttl);
print_r(PHP_EOL . $memcached->get($name) . PHP_EOL);

# run it
php test.php
```
