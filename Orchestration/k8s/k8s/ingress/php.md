```
---
# FASTGI PARAMS
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{ .Values.nginx.name }}"
data:
  SCRIPT_FILENAME: /var/www/html/app/web/index.php
  DOCUMENT_ROOT: /var/www/html/app/web/
  HTTP_PROXY: ""
  FASTCGI_PASS : "{{ .Values.php.name }}:9000"
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "{{ .Values.ingress.name }}"
  annotations:
    kubernetes.io/ingress.class: "nginx"
   #nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "FCGI"
    nginx.ingress.kubernetes.io/fastcgi-index: "index.php"
    nginx.ingress.kubernetes.io/fastcgi-params-configmap: "{{ .Values.nginx.name }}"
    nginx.ingress.kubernetes.io/use-regex: 'true'
    ingress.kubernetes.io/rewrite-target: /$1
    # define new location
    nginx.ingress.kubernetes.io/server-snippet: |
      location / {
          index index.php;
          if (!-e $request_filename){
              rewrite ^/(.*) /index.php?r=$1 last;
          }
      }
spec:
  tls:
    - hosts:
        - "{{ .Values.global.url }}"
  rules:
    - host: "{{ .Values.global.url }}"
      http:
        paths:
        # LOCATIONS
          - path: /(.*)
            pathType: Prefix
            backend:
              serviceName: php
              servicePort: fastcgi
          - path: >-
              /(.+\.(jpg|svg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|html|htm|ttf|woff|woff2))
            pathType: Prefix
            backend:
              serviceName: php
              servicePort: fastcgi
          - path: /(.+\.(php))
            pathType: Prefix
            backend:
              serviceName: php
              servicePort: fastcgi
```
```
# you can check config in controller
kubectl -n ingress-nginx exec --tty --stdin ingress-nginx-controller-56dd74d4d-jjcw5 -- /bin/bash
```
