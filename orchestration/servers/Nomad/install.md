```
@@@For nomad need installed consul agent on the same server
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install nomad –y
firewall-cmd --permanent --zone=public --add-port=4646-4648/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --reload


nano /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
StartLimitIntervalSec=10
TasksMax=infinity

[Install]
WantedBy=multi-user.target

mkdir --parents /etc/nomad.d
chmod 700 /etc/nomad.d
nano /etc/nomad.d/nomad.hcl

# connect config - external ip
advertise {
  http = "74.207.235.19"
}
bind_addr = "74.207.235.19"

data_dir = "/opt/nomad/data"
datacenter = "shakti_dc"

server {
  enabled = true
  bootstrap_expect = 2
}

client {
  enabled = true
}

consul {
  address             = "127.0.0.1:8500"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  # Enables automatically registering the services.
  auto_advertise      = true
  # Enabling the server and client to bootstrap using Consul.
  server_auto_join    = true
  client_auto_join    = true
}

systemctl enable nomad
systemctl start nomad
systemctl status nomad

http://127.0.0.1:4646/ui/jobs
nomad node status -address=http://192.168.196.55:4646

#firewalld
firewall-cmd --permanent --zone=public --add-port=4646-4648/tcp
firewall-cmd --reload
GUI
docker run --net=host -e NOMAD_ENABLE=1 -e NOMAD_ADDR=http://127.0.0.1:4646 -e CONSUL_ENABLE=1 -e CONSUL_ADDR=127.0.0.1:8500 -p 8000:3000 -d jippi/hashi-ui

```
