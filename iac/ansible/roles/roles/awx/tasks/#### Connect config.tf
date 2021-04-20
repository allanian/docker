#### Connect config
advertise_addr = 45.79.209.52
bind_addr = 45.79.209.52
client_addr = 0.0.0.0
data_dir = "/opt/consul"
datacenter = "company_dc"
domain = "consul"
node = "45.79.209.52"
#### Server only
connect {
  enabled = true
}
ui = true
server = true
bootstrap_expect = 1

#### Security config
encrypt = "zVWNi0V5TTzJEu2YHZGnfKFSg8daKbZtKyhXN5bhj0s="

#### Leave/Join
leave_on_terminate = False
skip_leave_on_interrupt = True
rejoin_after_leave = True
retry_join = ['45.79.207.123']

#### LOGS
log_level = DEBUG
log_file = /var/log/consul/
log_rotate_duration = 24h
log_rotate_max_files = 0
