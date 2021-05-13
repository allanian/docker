
# PERSISTENT VOLUMES
## EBS
```
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/

```

1. Create an IAM policy that allows the CSI driver's service account to make calls to AWS APIs on your behalf.:
```
export EBS_CSI_POLICY_NAME="Amazon_EBS_CSI_Driver" cluster_name="api-dev" region="us-east-2"
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

# dont need, go to the next step
#helm upgrade --install aws-ebs-csi-driver \
#  --version=0.10.2 \
#  --namespace kube-system \
#  --set serviceAccount.controller.create=false \
#  --set serviceAccount.snapshot.create=false \
#  --set enableVolumeScheduling=true \
#  --set enableVolumeResizing=true \
#  --set enableVolumeSnapshot=true \
#  --set serviceAccount.snapshot.name=ebs-csi-controller-irsa \
#  --set serviceAccount.controller.name=ebs-csi-controller-irsa \
#  aws-ebs-csi-driver/aws-ebs-csi-driver
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
```
