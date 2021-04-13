https://github.com/gruntwork-io/terraform-aws-couchbase/tree/master/examples/couchbase-ami
# AMI IMAGE WITH COUCHBASE - Amazon Linux 2
```
# how get access_key and secret_key
aws configure get aws_secret_access_key
aws configure get aws_access_key_id

git clone
cd couchbase-ami/
nano couchbase.json
  "variables": {
    "aws_region": "us-west-1",
    "edition": "enterprise",
    "base_ami_name": "couchbase",
    "AWS_ACCESS_KEY_ID": "",
    "AWS_SECRET_ACCESS_KEY":""
    
# To build an Amazon Linux AMI for Couchbase Enterprise: 
packer build -only=amazon-linux-ami -var edition=enterprise couchbase.json.
# When the build finishes, it will output the IDs of the new AMIs. 
us-west-1: ami-0c255294d6024f73b
```

# couchbase-cluster-dns-tls
```
cd couchbase-cluster-simple-dns-tls
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy
terraform init
terraform apply -var "key_pair_name=my_key"
# When done
terraform destroy -var "key_pair_name=my_key"
terraform init

# or create file with vars:
nano terraform.tfvars
ami_id="ami-0c255294"
domain_name="company.com"
cluster_name="dev"
ssh_key_name=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_DEFAULT_REGION="us-west-1"
terraform apply
