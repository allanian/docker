# Step-01: install eksctl
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/bin
eksctl version
```
# Step-02: Create Cluster
```
edit terraform.tfvars
terraform init
terraform apply
```
#### Get List of clusters
```
export region=us-east-2 cluster_name=api-dev
eksctl --region us-east-2 get clusters 
```
#### KubeConfig
```
aws eks --region $region update-kubeconfig --name $cluster_name
cp /root/.kube/configs/kubeconfig.yml /opt/.kube/configs/test.yml
export KUBECONFIG=$KUBECONFIG:/opt/.kube/configs/test.yml
kubectl get svc
```
#### delete cluster
```
terraform destroy
```