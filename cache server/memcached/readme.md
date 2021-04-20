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


```
; insert data in 1 thread to memcached
$memcached = new Memcached();
$memcached->addServer('NEED_TO_CHANGE', 11211);

$constantString = ' Just string to make value bigger!'
$constantString .= $constantString;
$constantString .= $constantString;
$constantString .= $constantString;
$constantString .= $constantString;
$constantString .= $constantString;

$ttl = 7200;

for ($i = 0; $i < 10000000; $i ++) {
    
    $uniqueString = time() . rand(0, 1000000000);
    $uniqueHash = md5($uniqueString);
    
    $memcached->set($uniqueHash, $uniqueString . $constantString , $ttl);
    $res = $memcached->get($uniqueHash);
    
    if ($i % 1000 == 0) {
        echo ($i * 1000) . ' values added! Last result is ' . $res. PHP_EOL;
    }
}


```

```
# benchmark tools
https://github.com/memcached/mc-crusher
```
## TEST
```
docker run --rm redislabs/memtier_benchmark:latest --server=10.3.3.232 --port=11211 --run-count=1 --requests=10000 --clients=50 --pipeline=1 --randomize

docker run --rm redislabs/memtier_benchmark:latest --server=10.3.3.232 --port=11211 --random-data --data-size-range=4-204 --data-size-pattern=S --key-minimum=200 --key-maximum=400

memtier-benchmark --random-data --data-size-range=4-204 --data-size-pattern=S --key-minimum=200 --key-maximum=400 <additional parameters>

In the example above, we’ve used the -–random-data switch to generate random data as well as the –key-minimum and –key-maximum switches to control the range of key name IDs, yielding a total of 200 keys. The first key, memtier-200, will hold 4 bytes of data, the next will have 5 bytes and so forth until the last key, memtier-400, which will store 204 bytes.


docker run --rm redislabs/memtier_benchmark:latest --server=10.3.3.232 --port=11211 
--random-data --data-size-range=100-100000 --data-size-pattern=S --key-minimum=200 --key-maximum=4000 --key-pattern=G:G --key-stddev=10 --key-median=300

docker run --rm redislabs/memtier_benchmark:latest  --server=10.3.3.232 --port=11211 \
--protocol=memcache_text --threads=20 --requests=1000000 --randomize \
--random-data --data-size-range=100-100000 --data-size-pattern=S --key-minimum=200 --key-maximum=4000 --key-pattern=G:G --key-stddev=10 --key-median=300

docker run --rm redislabs/memtier_benchmark:latest --protocol=memcache_text --server=10.3.3.232 --port=11211 --generate-keys --clients=150 --threads=10 --ratio=1:1 --key-pattern=R:R --key-minimum=16 --key-maximum=16 --data-size=128 --requests=100000 --run-count=20
```
