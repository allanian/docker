# Minio
# ON DNS
create 3 records
A minio1 ip
A minio2 ip
CNAME ms3.company.ru - minio1.company.ru

!!!рекомендовано создавать диски одного размера!!!
# ON ALL NODES
cat > /etc/hosts << EOF
10.3.3.1    minio1.company.ru 
10.3.3.2    minio2.company.ru
10.3.3.3    minio3.company.ru
10.3.3.4    minio4.company.ru
127.0.0.1     localhost
EOF

# Installation
```
wget -O /usr/bin/minio https://dl.minio.io/server/minio/release/linux-amd64/minio
chmod +x /usr/bin/minio
wget -O /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x /usr/bin/mc

# create data dir for MINIO
mkdir /data

# systemd
cat > /etc/systemd/system/minio.service << EOF
[Unit]
Description=minio
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/bin/minio

[Service]
WorkingDirectory=/data
User=root
Group=root
EnvironmentFile=/etc/default/minio
#ExecStartPre=/bin/bash -c "[ -z "${MINIO_VOLUMES}" ] && echo "Variable MINIO_VOLUMES not set in /etc/default/minio""
#ExecStartPre=/bin/bash -c "[ -z "${MINIO_ACCESS_KEY}" ] && echo "Variable MINIO_VOLUMES not set in /etc/default/minio""
#ExecStartPre=/bin/bash -c "[ -z "${MINIO_SECRET_KEY}" ] && echo "Variable MINIO_VOLUMES not set in /etc/default/minio""
ExecStart=/usr/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=on-success
StandardOutput=journal
StandardError=inherit
LimitNOFILE=65536
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no
KillSignal=SIGTERM
SuccessExitStatus=0

[Install]
WantedBy=multi-user.target
EOF
```

# README
#### минимум 2 ноды и по 1 диску, всегда должно быть эквивалентно 4!!!, но не больше 16 нод
```
cat > /etc/default/minio << EOF
MINIO_OPTS="--certs-dir /etc/ssl/rv-ssl --address :9000"
MINIO_VOLUMES="https://minio{1...4}.company.ru/data/data{1...1}"
MINIO_ROOT_USER="miniorv"
MINIO_ROOT_PASSWORD="SKFzHq5iDoQgW1gyNHYFmnNMYSvY9ZFMpH"
EOF
where:
#minio server http://host{1...n}/export{1...m}
#host{1...n} - hostname - minio1:9000
#export{1...m} - data folder - /data

systemctl daemon-reload
systemctl enable minio
systemctl start minio.service
systemctl status minio.service

systemctl restart minio.service
systemctl status minio.service
```
# Minio WebUI
http://10.3.3.1:9000

# SSL
```
copy cert to /etc/ssl
add this to MINIO_OPTS
 --certs-dir /etc/ssl
# Inside the certs directory, the private key must by named private.key and the public key must be named public.crt.
systemctl restart minio.service
systemctl status minio.service
```
## ALIAS
mc alias set <ALIAS> <YOUR-S3-ENDPOINT> [YOUR-ACCESS-KEY] [YOUR-SECRET-KEY] [--api API-SIGNATURE]
mc alias set s3 https://minio1.company.ru miniorv SKFzHq5iDoQgW1gyNHYFmnNMYSvY9ZFMpH --api S3v4
minio-mc alias set s3 https://minio1.company.ru miniorv SKFzHq5iDoQgW1gyNHYFmnNMYSvY9ZFMpH --api S3v4
# check - list bucket minio
mc ls s3



############### BUCKET
# alias
# list aliases
minio-mc alias ls
# remove alias minio
minio-mc rm minio
# create alias
minio-mc alias set s3 https://minio1.company.ru:9000 miniorv SKFzHq5iDoQgW1gyNHYFmnNMYSvY9ZFMpH


#Создаем подключение к Minio под названием s3.
minio-mc config host add s3 https://minio1.company.ru:9000 miniorv SKFzHq5iDoQgW1gyNHYFmnNMYSvY9ZFMpH

######################
POLICY
# list all policy
minio-mc admin policy list s3

consoleAdmin        
diagnostics         
readonly            
readwrite           
writeonly



#### BUCKET
# list of buckets
minio-mc ls
# tree
minio-mc tree s3
# size
minio-mc du s3
##Создаем bucket.
minio-mc mb s3/onec
minio-mc mb s3/clickhouse-backup

######## User
#список пользователей
mc admin user list TARGET
mc admin user list s3
mc admin user list --json s3
# создать юзера
mc admin user add TARGET USERNAME PASSWORD
# onec user
mc admin user add s3 yTzw7dbcgpXC9tPGPJmcr 5NYrz7fSZjnV4UCwcVeYv5ds2HsWufAjhAUYzmA
# удалить юзера from target s3
mc admin user remove s3 CFTC8ZKWDJCVJID2IJZ0
# policy for user
mc admin policy set s3 writeonly user=yTzw7dbcgpXC9tPGPJmcr
# info 
mc admin user info s3 CFTC8ZKWDJCVJID2IJZ0
#### GROUP
#добавить группу
mc admin group add TARGET GROUPNAME MEMBERS
# create group onec and add user
mc admin group add s3 onec yTzw7dbcgpXC9tPGPJmcr
# info about group
mc admin group info s3 onec
# list of groups
mc admin group list s3
# #назначить политику для группы (writeonly, readonly или readwrite)
mc admin policy set s3 writeonly group=onec
# list all users in group
mc admin user list s3

#перезагрузка кластера
mc admin service restart minio 
# SYSTEM INFO
minio-mc admin config get s3 region
minio-mc stat s3

# CLICKHOUSE
# bucket
minio-mc mb s3/clickhouse-backup
# user clickhouse
minio-mc admin user add s3 clickhouse iHZ1Fh76nUtxcNNTWumqNrF5tucqp82GKBIcGwol
minio-mc admin policy set s3 writeonly user=clickhouse
# group
minio-mc admin group add s3 clickhouse clickhouse
minio-mc admin policy set s3 writeonly group=clickhouse
minio-mc admin group info s3 clickhouse

# policy
nano {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:ListAllMyBuckets",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::clickhouse-backup"
      ],
      "Sid": ""
    },
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::clickhouse-backup/*"
      ],
      "Sid": ""
    }
  ]
}
minio-mc admin policy add s3 clickhouse-backup-policy user.json
minio-mc admin policy set s3 clickhouse-backup-policy user=clickhouse
minio-mc admin user list s3
# test
minio-mc config host add clickhouse-backup https://ms3.company.ru clickhouse iHZ1Fh76nUtxcNNTWumqNrF5tucqp82GKBIcGwol



# test - create file with name test and size 5gb
dd if=/dev/urandom of=test bs=1M count=5000
dd if=/dev/zero of=q bs=1M count=1000 oflag=direct oflag=sync
# 30mb/sec
minio-mc cp test s3/clickhouse-backup/test

echo test11 >> test.1
minio-mc cp test.1 s3/clickhouse-backup/test.1
# check files
minio-mc stat s3/clickhouse-backup
minio-mc cat s3/clickhouse-backup/test.1
minio-mc ls s3/clickhouse-backup/test.1

# SYSTEM
minio-mc admin info s3

# S3
s3cmd --configure






# ceph
radosgw-admin user list
radosgw-admin user create --uid=test1 --display-name="Test1" --email=test1@test.ru




"user": "onec",
"access_key": "yTzw7dbcgpXC9tPGPJmcr",
"secret_key": "5NYrz7fSZjnV4UCwcVeYv5ds2HsWufAjhAUYzmA"
web




# minio
размер стореджа по самому маленькому диску!!!

docker run -d -p 9001:9000 -e "MINIO_ACCESS_KEY=KM9IL4OSS15P0H2TMWPP" -e "MINIO_SECRET_KEY=RQQny9tMVNg0uv1AbVSmykkINhe86UpEgRq+TWLV" -v /data/minio-data:/data -d minio/minio server /data

https://github.com/minio/minio



