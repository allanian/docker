bootstrap = true
server=true
datacenter = "shakti_dc1"
data_dir = "/consul/data"
#encrypt = "wRGj8klsrzi5rqfdr50VtpEAyLxMO0cvNsbvCvvzlnQ="
#enable_syslog = true
ui=true
client_addr = "0.0.0.0"
node_name = "consul-bootstrap"
connect {
  enabled = true
}
acl = {
  enabled = true
  default_policy = "allow"
  down_policy = "allow"
}
acl_master_token = "49792521-8362-f878-5a32-7405f1783838"
leave_on_terminate = false
skip_leave_on_interrupt = true
rejoin_after_leave = true
log_level = "DEBUG"
log_file = "/consul/logs"
log_rotate_duration = "24h"
log_rotate_max_files = 0
