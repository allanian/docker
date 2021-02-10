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
