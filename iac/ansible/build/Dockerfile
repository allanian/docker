# Dockerfile ansible based on apline image.

FROM alpine:3.10.2

MAINTAINER Narilien


RUN apk add --no-cache --update sudo git && \
    apk add --no-cache python3 py3-pip openssl ca-certificates && \
    apk add --no-cache --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base && \
    pip3 install --upgrade pip cffi pyvmomi pynetbox==4.3.3 mitogen && \
    \
    echo "#################### Installing Ansible" && \
    pip3 install ansible && \
    \
    pip3 install --upgrade pycrypto pywinrm && \
    apk --no-cache --update add sshpass openssh-client bash rsync && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts
# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
