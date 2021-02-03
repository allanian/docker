# Prometheus info
Состоит из трёх компонент, написанных на go:

 - prometheus — ядро, собственная встроенная база данных и
   веб-интерфейс. 
 - node_exporter — агент, который может быть установлен
   на другой сервер и пересылать метрики в ядро, работает  только с
   prometheus. 
 - alertmanager — система уведомлений.

## CONFIG
### TARGETS
Targets for monitoring
```
nano prometheus.yml
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'
```

### RULES
Rules for alerts
```
nano prometheus.yml
rule_files:
- /etc/prometheus/rules/*.rules

nano /etc/prometheus/rules/nginx.rules
groups:
- name: ansible managed alert rules
rules:
###### LINUX Monitoring
- alert: InstanceDown
  annotations:
    description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
    summary: Instance {{ $labels.instance }} down
  expr: up == 0
  for: 5m
  labels:
    severity: critical

systemctl reload Prometheus
```
