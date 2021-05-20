```
Warning: nginx-php-fpm-ingress - DONT WORKING WITH STATIC FILES, better use sidecar nginx
1) Config map - php-fpm conf
listen = 0.0.0.0:9000
2) Service php-fpm
service php-fpm
  - name: php-fpm
    port: 80
    targetPort: 9000
    protocol: TCP
3) config-map for ingress
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-cm
data:
  DOCUMENT_ROOT: "/var/www/html/app/web"
  SCRIPT_FILENAME: "/var/www/html/app/web/index.php"
4) ingress php-fpm
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-body-size: 100m
    # check
    nginx.ingress.kubernetes.io/backend-protocol: "FCGI"
    nginx.ingress.kubernetes.io/fastcgi-index: "index.php"
    nginx.ingress.kubernetes.io/fastcgi-params-configmap: "ingress-cm"
    nginx.ingress.kubernetes.io/fastcgi_buffers: "16 16k"
    nginx.ingress.kubernetes.io/fastcgi_buffer_size: "32k"
5) deployment - php-fpm. add this:
        ports:
        - containerPort: 9000
          name: php-fpm


```
