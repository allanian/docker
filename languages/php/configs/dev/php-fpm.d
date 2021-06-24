[www]
user = nginx
group = nginx
; listen
listen = /var/run/php-fpm/php-fpm.sock
listen.backlog = 65535
listen.allowed_clients = 127.0.0.1
listen.owner = nginx
listen.group = nginx
listen.mode = 0666
; PM
pm = ${PHP_PM_MODE}
pm.max_children = ${PHP_MAX_CHILDREN}
pm.start_servers = ${PHP_START_SERVERS}
pm.min_spare_servers = ${PHP_MIN_SPARE_SERVERS}
pm.max_spare_servers = ${PHP_MAX_SPARE_SERVERS}
pm.process_idle_timeout = 10s
pm.max_requests = 3000
; Status page
pm.status_path = /status
ping.path = /ping
; logging
php_admin_flag[log_errors] = on
php_flag[display_errors] = on
php_admin_flag[display_startup_errors]= yes
php_admin_value[error_log] = /proc/1/fd/2
access.log = /proc/1/fd/1
slowlog = /proc/1/fd/2
; max exec time for request
request_terminate_timeout = 1m
request_slowlog_timeout = 6s
; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes
; limits
rlimit_files = 131070
env[HOSTNAME] = $HOSTNAME
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
; php 
php_admin_value[memory_limit] = 512M
;php_value[session.save_handler] = files
;php_value[session.save_path] = /var/lib/php/session
php_value[session.save_handler] = memcached
php_value[session.save_path] = "tcp://${MEMCACHED1},tcp://${MEMCACHED2}"
php_value[soap.wsdl_cache_enabled] = 1
php_value[soap.wsdl_cache] = 2
php_value[soap.wsdl_cache_ttl] = 3600
php_value[soap.wsdl_cache_limit] = 10

