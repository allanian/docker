
# PERSISTENT VOLUMES
## EBS
```
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/


#curl https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/deploy/kubernetes/secret.yaml > secret.yaml
## Edit the secret with user credentials
#kubectl apply -f secret.yaml



```

1. Create an IAM policy that allows the CSI driver's service account to make calls to AWS APIs on your behalf.:
```
curl -o example-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json
# Create an IAM policy called Amazon_EBS_CSI_Driver:
aws iam create-policy \
  --region $region \
  --policy-name $EBS_CSI_POLICY_NAME \
  --policy-document file://example-iam-policy.json

# export the policy ARN as a variable
export EBS_CSI_POLICY_ARN=$(aws --region $region iam list-policies --query 'Policies[?PolicyName==`'$EBS_CSI_POLICY_NAME'`].Arn' --output text)
echo $EBS_CSI_POLICY_ARN

Мы попросим eksctlсоздать роль IAM, содержащую только что созданную политику IAM, и связать ее с вызываемой учетной записью службы Kubernetes, ebs-csi-controller-irsaкоторая будет использоваться драйвером CSI:
# Create an IAM OIDC provider for your cluster
eksctl utils associate-iam-oidc-provider \
  --region=$region \
  --cluster=$cluster_name \
  --approve

# Create a service account
eksctl create iamserviceaccount \
  --region=$region \
  --cluster $cluster_name \
  --name ebs-csi-controller-irsa \
  --namespace kube-system \
  --attach-policy-arn $EBS_CSI_POLICY_ARN \
  --override-existing-serviceaccounts \
  --approve

# Развертывание драйвера Amazon EBS CSI
# ===========================================================
# Install, with HELM
# ===========================================================
# add the aws-ebs-csi-driver as a helm repo
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
# search for the driver
helm search  repo aws-ebs-csi-driver

helm upgrade --install aws-ebs-csi-driver \
  --version=0.10.2 \
  --namespace kube-system \
  --set serviceAccount.controller.create=false \
  --set serviceAccount.snapshot.create=false \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true \
  --set serviceAccount.snapshot.name=ebs-csi-controller-irsa \
  --set serviceAccount.controller.name=ebs-csi-controller-irsa \
  aws-ebs-csi-driver/aws-ebs-csi-driver
# NOTE: NEED TO CREATE STORAGE CLASS or use with values.yaml
# OR WITH VALUES.yaml with defined storage class
helm upgrade --install aws-ebs-csi-driver \
  --version=0.10.2 \
  --namespace kube-system \
  -f values.yaml \
  aws-ebs-csi-driver/aws-ebs-csi-driver

kubectl -n kube-system rollout status deployment ebs-csi-controller
# check
kubectl get pod -n kube-system -l "app.kubernetes.io/name=aws-ebs-csi-driver,app.kubernetes.io/instance=aws-ebs-csi-driver"

# dont need if used values.yaml with storage class
Dynamic Volume Provisioning allows storage volumes to be created on-demand. StorageClass should be pre-created to define which provisioner should be used and what parameters should be passed when dynamic provisioning is invoked.
# ===========================================================
# STORAGE CLASS
# ===========================================================
cat << EoF > storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: gp2
provisioner: ebs.csi.aws.com # Amazon EBS CSI driver
parameters:
  type: gp2
  encrypted: 'true' # EBS volumes will always be encrypted by default
reclaimPolicy: Delete
mountOptions:
- debug
EoF




# DONT NEED!
```
2. Create an IAM role and attach the IAM policy to it:
```
a. View your cluster's OIDC provider URL.
aws eks describe-cluster --name $cluster_name --region=$region --query "cluster.identity.oidc.issuer" --output text
b. Create the IAM role:
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/<XXXXXXXXXX45D83924220DC4815XXXXX>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-west-2.amazonaws.com/id/<XXXXXXXXXX45D83924220DC4815XXXXX>:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF
# replace YOUR_AWS_ACCOUNT_ID with your account ID. Replace XXXXXXXXXX45D83924220DC4815XXXXX with the value returned in step 4.
# how get account id
aws sts get-caller-identity --query 'Account' --output text
	
### Create an IAM role:
aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"trust-policy.json"
  
c. Attach your new IAM policy to NodeInstanceRole:
aws iam attach-role-policy \
--policy-arn arn:aws:iam::111122223333:policy/AmazonEKS_EBS_CSI_Driver_Policy \
--role-name AmazonEKS_EBS_CSI_DriverRole 
Note: Replace the policy Amazon Resource Name (ARN) with the ARN of the policy created in the preceding step 2. Replace the role name with NodeInstanceRole.
# aws iam list-policies --query 'Policies[?PolicyName==`AmazonEKS_EBS_CSI_Driver_Policy`].Arn' --output text



# ===========================================================
# Install, with MANIFEST
# ===========================================================
# DONT NEED
7. To deploy the Amazon EBS CSI driver, run one of the following commands based on your AWS Region:
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
8. Annotate the ebs-csi-controller-sa Kubernetes service account with the ARN of the IAM role that you created earlier:
kubectl annotate serviceaccount ebs-csi-controller-sa \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/AmazonEKS_EBS_CSI_DriverRole
Note: Replace YOUR_AWS_ACCOUNT_ID with your account ID.
note: get account id
aws sts get-caller-identity --query 'Account' --output text
9.    Delete the driver pods, the auto redeployed with ID:
kubectl delete pods \
  -n kube-system \
  -l=app=ebs-csi-controller
```
