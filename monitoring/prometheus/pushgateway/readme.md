```
pushgateway.service
[Unit]
Description=Pushgateway Service
After=network.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway --persistence.file="/tmp/metric.store" --persistence.interval=5m --log.level=info --log.format=json --web.listen-address=:9091 --web.telemetry-path=/metrics
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
