
```
# PHP_FPM monitoring

You would need to set up the default vhost in apache (000-default???) to handle /status and /ping. I use nginx (apologies, but adapt as needed) and my default file has the following location directive:

location ~ ^/(status|ping)$ {
    ## disable access logging for request if you prefer
    access_log off;
    chunked_transfer_encoding off;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_index index.php;
    fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
    #fastcgi_pass 127.0.0.1:9000;
    #fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;

    allow 127.0.0.1;
    allow ::1;
    deny all;
}


Which then allows me to curl localhost/status.

You also need to change your php-fpm conf (mine is www.conf) and uncomment the lines:

pm.status_path = /status
ping.path = /ping


	
PHP-FPM: Ping is down
# MANUAL TEST OF ZABBIX AGENT METRICS
zabbix_agent2 -t web.page.get["localhost","/ping","80"]
```
