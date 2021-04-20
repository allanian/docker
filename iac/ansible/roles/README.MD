Create Gitlab-runner on server with ansible (change description, token and etc.)

example command:
gitlab-runner register 
--non-interactive 
--url "https://git2.company.org/" 
--registration-token "qs-12MtctyWav8wdxc2z" 
--description "ansible" 
--tag-list "ansible" 
--executor "shell" 
--run-untagged true


AUTO-COPY PUBLIC KEY TO REMOTE SERVERs:
Whats required:

server with ansible;
password from user with sudo and her public key;

Order of action:

public key copy to /roles/pre_role/files/id_rsa.pub
we save the password from the user in ansible-vault
on server with ansible run command:
ansible-vault create secret
and copy this to /roles/pre_role/files/secret
save created password for ansible-vault in gitlab vars with name - ANSIBLE_VAULT_PASSWORD

How its work:

First - take all hosts from inventory and save in known_hosts on ansible-server
Second - connect to all hosts from inventory with password from ansible-vault
Third - copy public_key user into $HOME/.ssh/authorized_keys for all hosts in inventory
Fourth - change user in main.yml - task - name: copy key on remote machine (user: root)
Fifth - edit your .gitlab-ci.yml - run playbook with your user, example: -u root or -u deploy

ansible-playbook pre_playbook.yml -i hosts -u root --vault-password-file=./roles/pre_role/files/vault.txt



# FOR CREATE VM
### Playbook for create and configure VMs from template with ansible.

��������:
####��������
                
1. �������������� hosts (������� ��������� ip �� netbox � �.�.);
2. �������������� main.yml (������� hosts: �� ������)
3. ���������� CI/CD => pipeline => job - infra �������
4. ������ � netbox ����������� ��������� �����