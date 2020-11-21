datacenter = "company_dc1"
data_dir = "/tmp/data"
domain = "livelinux"
server=true
#node_name = "consul-server-01"
connect {
  enabled = true
}
leave_on_terminate = false
skip_leave_on_interrupt = true
rejoin_after_leave = true
acl = {
  enabled = true
  default_policy = "allow"
  down_policy = "allow"
}
acl_master_token = "49792521-8362-f878-5a32-7405f1783838"
log_level = "INFO"
log_file = "/tmp/logs"
log_rotate_duration = "24h"
log_rotate_max_files = 0
