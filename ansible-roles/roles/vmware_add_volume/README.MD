# CREATE VMs from template and add volume

1) delete nic from template
2) change inventory
# INVENTORY

[testvm]
grr_test1  ansible_host='127.0.0.1' guest_network='VLAN_150' guest_netmask='255.255.255.0' guest_gateway='127.0.0.254' guest_template='centos7_template_NIC_removed' guest_add_disk='yes' join_domain='yes' 
grr_test2  ansible_host='127.0.0.2' guest_network='VLAN_150' guest_netmask='255.255.255.0' guest_gateway='127.0.0.254' guest_template='centos7_template_NIC_removed' guest_add_disk='no' join_domain='no'
