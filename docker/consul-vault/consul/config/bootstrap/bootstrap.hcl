node=consul-01
#acl = {
#  enabled = true
#  default_policy = "allow"
#  down_policy = "allow"
#}
#acl_master_token = "49792521-8362-f878-5a32-7405f1783838"
advertise_addr = "45.79.207.123"
bind_addr = "45.79.207.123"
bootstrap_expect=1
client_addr = "0.0.0.0"
connect {
  enabled = true
}
datacenter = "company_dc"
data_dir = "/opt/consul"
dns_config {
  enable_truncate = true
  only_passing = true
}
domain = "consul"
enable_script_checks = true
encrypt = "wRGj8klsrzi5rqfdr50VtpEAyLxMO0cvNsbvCvvzlnQ="
server = true
ui = true

#### LOGS
log_level = "DEBUG"
log_file = "/consul/logs"
log_rotate_duration = "24h"
log_rotate_max_files = 0

#### Leave/Join
leave_on_terminate = false
skip_leave_on_interrupt = true
rejoin_after_leave = true
retry_join = ["45.79.207.123"]
start_join {
  consul-01
}
