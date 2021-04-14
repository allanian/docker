# build AMI image to AWS
packer build -only=amazon-linux-ami -var edition=enterprise couchbase.json
