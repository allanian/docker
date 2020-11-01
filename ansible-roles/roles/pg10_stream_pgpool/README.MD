#
# INVENTORY
[PG_MASTER]
127.0.0.1 ansible_ssh_pass='QWE123qwe'

[PG_REPLICA]
127.0.0.2 ansible_ssh_pass='QWE123qwe'
127.0.0.3 ansible_ssh_pass='QWE123qwe'

[postgres:children]
PG_MASTER
PG_REPLICA
