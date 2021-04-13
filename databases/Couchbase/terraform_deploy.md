https://github.com/gruntwork-io/terraform-aws-couchbase/tree/master/examples/couchbase-ami
aws configure get aws_secret_access_key
aws configure get aws_access_key_id

cd ami
nano couchbase.json
To build an Amazon Linux AMI for Couchbase Enterprise: packer build -only=amazon-linux-ami -var edition=enterprise couchbase.json.
When the build finishes, it will output the IDs of the new AMIs. 
us-west-1: ami-0c255294d6024f73b

go to couchbase-cluster-simple-dns-tls
nano variables.tf

terraform init

nano variables.tf
```
variable "AWS_DEFAULT_REGION" {
  type        = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
}
```
nano terraform.tfvars
ami_id="ami-0c255294"
domain_name="company.com"
cluster_name="dev"
ssh_key_name=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_DEFAULT_REGION="us-west-1"
terraform apply
