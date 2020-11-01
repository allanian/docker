# -----------------------------------------------------------------------
# Global configuration
# set via env variables
# -----------------------------------------------------------------------
ui = true
# -----------------------------------------------------------------------
# Listener configuration
# -----------------------------------------------------------------------
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
#   #tls_cert_file = "/etc/ssl/certs/vault-server.crt"
#   #tls_key_file  = "/etc/ssl/vault-server.key"
}
cluster_address = "0.0.0.0:8201"
cluster_name = "Primary"
# -----------------------------------------------------------------------
# Storage configuration
# -----------------------------------------------------------------------
#storage "file" {
#  path = "/vault/data"
#}
 

storage "consul" {
  address = "consul-bootstrap:8500"
  path    = "vault/"
  scheme = "http"
  token = "49792521-8362-f878-5a32-7405f1783838"
#  tls_ca_file        = "/etc/ssl/certs/ca.pem"
# disable_clustering = "${disable_clustering}"
# service_tags       = "${service_tags}"
}

# -----------------------------------------------------------------------
# Optional cloud seal configuration
# -----------------------------------------------------------------------

# GCPKMS

# -----------------------------------------------------------------------
# Enable Prometheus metrics by default
# -----------------------------------------------------------------------

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = false
}
raw_storage_endpoint = true