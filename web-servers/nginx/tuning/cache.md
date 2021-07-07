# FRONTEND CACHE
```
# create folder for cache
mkdir /var/www/example.com/cache/
# add cache config to http block
nano /etc/nginx/nginx.conf
proxy_cache_path /var/www/example.com/cache/ keys_zone=one:10m max_size=500m inactive=24h use_temp_path=off;

keys_zone=one:10m sets a 10 megabyte shared storage zone (simply called one, but you can change this for your needs) for cache keys and metadata.
max_size=500m sets the actual cache size at 500 MB.
inactive=24h removes anything from the cache which has not been accessed in the last 24 hours.
use_temp_path=off writes cached files directly to the cache path. This setting is recommended by NGNIX.

# add to server block
nano /etc/nginx/conf.d/example.com.conf
  proxy_cache one;
  location / {
    proxy_pass http://ip-address:port;
  }

# for clear cache 
find /var/www/example.com/cache/ -type f -delete
```
