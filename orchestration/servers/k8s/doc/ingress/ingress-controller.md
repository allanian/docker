# INGRESS CONTROLLER 
## Installation
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
kubectl label node node2 ingress=
# delete label ingress
kubectl label node node1 ingress-

# create default ssl certificate
kubectl create secret tls tls-secret --key rendez-vous.key --cert rendez-vous.crt -n ingress-nginx

helm delete ingress-nginx -n ingress-nginx
#additionalLabels.release - name of prometheus stack
helm upgrade --install ingress-nginx -n ingress-nginx ingress-nginx/ingress-nginx  \
  --set controller.service.type=NodePort \
  --set controller.hostNetwork=true \
  --set controller.replicaCount=2 \
  --set controller.extraArgs.default-ssl-certificate=ingress-nginx/tls-secret \
  --set controller.nodeSelector."ingress"='' \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release=prometheus
```
# INGRESS CONTROLLER OPTIMIZATION
## GZIP
```
kubectl edit configmap -n ingress-nginx ingress-nginx-controller
#### add this
data: # ADD IF NOT PRESENT
  use-gzip: "true" # ENABLE GZIP COMPRESSION
  gzip-types: "*" # SPECIFY MIME TYPES TO COMPRESS ("*" FOR ALL) 
```
### how check it
```
Checking with Developer tools with a browser of your choosing:
Chrome -> F12 -> Network -> Go to site (or refresh) and press on example file (look on Response Header):
CONTEND-ENCODING: gzip
```
