# CONFIGs
nano load.yaml
```
# PERFOMANCE TOOL
phantom:
  address: zhuravsky.rendez-vous.ru:443 # [Target's address]:[target's port]
  ssl: true
  uris: # !!! don't use it with ammofile
    - "/"
    - "/catalog/"
  load_profile:
    load_type: rps # schedule load by defining requests per second
    schedule: line(10, 100, 10s) # starting from 1rps growing linearly to 10rps during 10 minutes
    #schedule: line(1000, 10000, 10s)
  writelog: all
  header_http: "1.1"
  headers:
    - "[Host: www.target.example.com]"
    - "[Connection: close]" 
  instances: 20000 # Thread limits

# stop if timeout more then 5%
autostop:
  autostop:
    #- time(10s,15s) # stop, IF average response time higher than 5000ms for 15s
    #- http(5xx,100%,1s)
    - net(110, 5%, 10s) # stop if timeout more then 5%
console:
  enabled: true # enable console output

# MONITOR SYSTEM STATS (dont forget to copy ssh-key from server with yandex tank to the server with service)
telegraf:
  enabled: false
  config: monitoring.xml
  kill_old: false
  package: yandextank.plugins.Telegraf
  ssh_timeout: 30s

# WEB REPORTS
overload:
  token_file: token.txt
  job_name: test
  job_dsc: test description
```
# Run
```
docker run  \
  --entrypoint /bin/bash    \
  -v $(pwd):/var/loadtest   \
  -v $HOME/.ssh:/root/.ssh  \
  --net host                \
  -it direvius/yandex-tank
  
yandex-tank -c load.yaml
```
