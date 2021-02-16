```
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config
data:
  nginx.conf: |
    server_tokens off;
    server {
      listen 80 default_server;
      server_name _;

      client_body_buffer_size 32k;

      location / {
        rewrite ^ /index.php$is_args$args;
      }

      location ~ ^/index\.php(/|$) {
        client_max_body_size 0;
        root /var/www/emarsys/public;
        #fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $document_root;
        fastcgi_intercept_errors off;
        fastcgi_read_timeout 300;
        proxy_connect_timeout       600;
        proxy_send_timeout          600;
        proxy_read_timeout          600;
        send_timeout                600;
      }
    }
  stats.conf: |
    server {  # stats export
        listen 127.0.0.1:8080 default_server;
        server_name _;
        location = /stub_status {
            stub_status;
        }

        location ~ ^/(status|ping)$ {
          allow 127.0.0.1;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_index index.php;
          include fastcgi_params;
          fastcgi_pass 127.0.0.1:9000;
          fastcgi_intercept_errors off;
          fastcgi_read_timeout 300;
          #fastcgi_pass   unix:/var/run/php7.2-fpm.sock;
        }

    }
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: php-config
data:
  zz-docker.conf: |
    [global]
    daemonize=no
    ;logging
    error_log = /proc/self/fd/2
    ;error_log = /tmp/error.log
    log_limit = 8192
    log_level = debug
    [www]
    ;listen=/var/run/php/php-fpm.sock
    listen = 127.0.0.1:9000
    listen.mode=0666
    ping.path = /ping
    ping.response = pong
    pm = dynamic
    ;pm=static
    pm.start_servers = 10
    pm.min_spare_servers = 10
    pm.max_spare_servers = 25
    pm.max_children=40
    pm.max_requests=1000
    php_admin_flag[allow_url_include]=off
    php_admin_flag[assert.active]=off
    php_admin_value[max_execution_time]=30
    php_admin_flag[session.use_strict_mode]=On
    php_admin_value[realpath_cache_ttl]=3600
    php_admin_flag[zend.detect_unicode]=Off
    ; logging
    php_admin_flag[log_errors]=on
    access.log = /proc/self/fd/2
    ;access.log = /tmp/access.log
    slowlog = /proc/self/fd/2
    ;slowlog = /tmp/slow.log
    request_slowlog_timeout = 10s
    request_slowlog_trace_depth = 50
    request_terminate_timeout = 360
    ; Ensure worker stdout and stderr are sent to the main error log.
    catch_workers_output = yes
    pm.status_path=/status
    php_admin_flag[display_errors]= yes
    php_admin_flag[display_startup_errors]= yes
    ; limits
    rlimit_files = 131070
    rlimit_core = unlimited
    php_admin_value[memory_limit] = 4096M
    php_admin_value[max_execution_time] = "120"
    php_admin_value[output_buffering] = "4096"
    php_admin_value[post_max_size] = "100M"
    php_admin_value[upload_max_filesize] = "100M"
```
