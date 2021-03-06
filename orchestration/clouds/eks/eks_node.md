
 - [Install tool](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-01-install-eksctl)
 - [Create cluster](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-02-create-cluster)
 - [Create & Associate IAM OIDC Provider for our EKS Cluster](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-03-create--associate-iam-oidc-provider-for-our-eks-cluster)
 - [IAM policy for AWS ALB](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-04--iam-policy-for-the-aws-load-balancer-controller)
 - [IAM role](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-05--create-a-iam-role-and-serviceaccount-for-the-load-balancer-controller-use-the-arn-from-the-step-above)
 - [AWS ALB deployment](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-06-install-aws-load-balancer-controller)
 - 
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
#  Step-03: Create & Associate IAM OIDC Provider for our EKS Cluster
### Step-02.1: Create an IAM policy for the service account 
**Note:** The ALB Ingress Controller requires several API calls to provision the ALB components for the ingress resource type. 
#### verify
```
export KUBECONFIG=/opt/.kube/configs/test.yml
export region=us-east-2 cluster_name=api-dev
aws eks describe-cluster --region $region --name $cluster_name --query "cluster.identity.oidc.issuer" --output text
```
Пример вывода:
```
https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E
```
Так же можно проверить его тут:    
https://console.aws.amazon.com/iamv2/home?#/identity_providers
Перечислите поставщиков IAM  OIDC в своей учетной записи. Заменить <EXAMPLED539D4633E53DE1B716D3041E>(включая <>) значением, возвращенным предыдущей командой.
```
aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>
```
Если результат возвращается предыдущей командой, значит, у вас уже есть провайдер для вашего кластера - **GO TO THE STEP 04**. Если выходные данные не возвращаются, необходимо создать поставщика IAM  OIDC.
Create an IAM OIDC identity provider for your cluster:
```
eksctl utils associate-iam-oidc-provider --region $region --cluster $cluster_name --approve
#### verify
aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>
``` 
# STEP 04:  IAM policy for the AWS Load Balancer Controller
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```
```
# Create IAM POLICY with name - AWSLoadBalancerControllerIAMPolicy
aws iam create-policy \
--region=$region \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam-policy.json
```
# STEP 05:  Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above
```
# how get arn of policy
aws iam list-policies --query 'Policies[?PolicyName==`AWSLoadBalancerControllerIAMPolicy`].Arn' --output text

## Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above
eksctl create iamserviceaccount \
  --cluster=$cluster_name \
  --region=$region \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::21312313213:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```
####  To verify that the new service role was created, run the following command:
```
eksctl get iamserviceaccount --region=$region --cluster=$cluster_name --namespace kube-system
```
**Note:** The role name begins with **eksctl-your-cluster-name-addon-iamserviceaccount-**.

# Step-06: Install aws-load-balancer-controller

    #Add the EKS repository to Helm:
    helm repo add eks https://aws.github.io/eks-charts
    # update repo
    helm repo update
    #Install the TargetGroupBinding CRDs:
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    
    # Install the AWS Load Balancer controller, if using iamserviceaccount
    export vpc=$(aws eks describe-cluster --region $region --name $cluster_name --query "cluster.resourcesVpcConfig.vpcId" --output text)
    helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
    --set clusterName=$cluter_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set vpcId=$vpc \
    --set region=$region
    
    # Additional options
    https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
  
**uninstall**
```
helm delete aws-load-balancer-controller -n kube-system
```
**To check the status of the  **alb-ingress-controller**  deployment, run the following command:**
```
kubectl -n kube-system get pod
```
#### EXAMPLE for check AWX-LB-controller
nano 2048.yml
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: game-2048
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-2048
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 5
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: alexwhen/docker-2048
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  namespace: game-2048
  name: service-2048
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: NodePort
  selector:
    app.kubernetes.io/name: app-2048
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: service-2048
            port: 
              number: 80
```
```
kubectl apply -f 2048.yml
kubectl get pods -n game-2048
kubectl get ingress -n game-2048
```
##### copy ADDRESS and paste to Browser

## ExternalDNS
#### Used for Updating Route53 RecordSets from Kubernetes

 - [x] 1. create iam policy, copy ID
 - [x] 2. create iam role and attach policy ID
 - [x] 3. create service account in k8s and attach role ID 

https://www.stacksimplify.com/aws-eks/aws-alb-ingress/install-externaldns-on-aws-eks/
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md

### 1. IAM Policy

Перейдите в Services -> IAM -> Policies -> Create Policy -> Json Tab -> paste json below
[create iam policy ](https://console.aws.amazon.com/iam/home#/policies$new?step=edit)

- Click on  **JSON**  Tab and copy paste below JSON
-   Click on  **Visual editor**  tab to validate
-   Click on  **Review Policy**
	-   **Name:**  AllowExternalDNSUpdates
	-   **Description:**  Allow access to Route53 Resources for ExternalDNS
-   Click on  **Create Policy**
```
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    }
```

Запишите Политику ARN, которую мы будем использовать на следующем шаге.
arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates

### IAM Role, k8s Service Account & Associate IAM Policy
[Readme here](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
In addition, we are also going to associate the AWS IAM Policy AllowExternalDNSUpdates to the newly created AWS IAM Role.
Create IAM Role, k8s Service Account & Associate IAM Policy

#### IAM SERVICE ACCOUNT with policy AllowExternalDNSUpdates
**Replaced name, namespace, cluster, arn** (also you can attach it manually from aws=>iam=>policy=>usage console)
**if you create role in region, where you already HAVE FARGATE CLUSTER change name to external-dns1**
```
# how get arn of policy 
aws iam list-policies --query 'Policies[?PolicyName==`AllowExternalDNSUpdates`].Arn' --output text
# or here https://console.aws.amazon.com/iam/home#/policies AWS=>IAM=>POLICY=>NAME=>ARN ID
# Edit attach-policy-arn
eksctl create iamserviceaccount \
--name external-dns \
--region=$region \
--namespace default \
--cluster=$cluster_name \
--attach-policy-arn arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates \
--approve \
--override-existing-serviceaccounts
```
**Verify the Service Account**
```
kubectl get sa external-dns
```
**Update External DNS Kubernetes manifest**
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
## ExternalDNS
### 1. get iam role ARN
-   Go to AWS -> Services -> CloudFormation
-   Verify the latest CloudFormation Stack created. (`eksctl` external-dns)
-   Click on **Resources**  tab
-   Click on link in **Physical ID** field which will take us to **IAM Role** directly
### 2. Verify IAM Role & IAM Policy
- On step Above, we created IAM ROLE for EXTERNAL DNS!, so we need FULL ROLE ARN OF THAT!
- you can get **ROLE ARN** it from IAM=>POLICY=>USAGE - role with name of your cluster, then go inside and COPY ROLE ARN!!!!
```
    arn:aws:iam::180789647333:role/eksctl-eksdemo1-addon-iamserviceaccount-defa-Role1-1O3H7ZLUED5H4
```
### 3. Changes in file:
-   Change-1: Line number 9: IAM Role update[Iam role update¶](https://www.stacksimplify.com/aws-eks/aws-alb-ingress/install-externaldns-on-aws-eks/#change-1-line-number-9-iam-role-update)
-    Change-2: Line 55, 56: Commented them
```

# If you're using kiam or kube2iam, specify the following annotation.
# Otherwise, you may safely omit it.
#55   annotations:
#56      iam.amazonaws.com/role: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME

#  --domain-filter=external-dns-test.my-org.com
#  - --policy=upsert-only
```
**config**
!! verify, rbac enabled or no
- first we create policy
- copy policy arn
- attach policy arn to SA, then we create
```
kubectl api-versions | grep rbac.authorization.k8s.io
nano external_dns.yml
```
**if you create CLUSTER IN REGION, where you already have FARGATE, please change name external-dns to external-dns1**
**ALSO CHANGE --txt-owner-id=QA**

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: kube-system
  # If you're using Amazon EKS with IAM Roles for Service Accounts, specify the following annotation.
  # Otherwise, you may safely omit it.
  annotations:
    # paster Role ARN
    #eks.amazonaws.com/role-arn: arn:aws:iam::**AWS-ACCOUNT-ID**:role/**IAM-SERVICE-ROLE-NAME**
    eks.amazonaws.com/role-arn: arn:aws:iam::180789647333:role/eksctl-eksdemo1-addon-iamserviceaccount-defa-Role1-1O3H7ZLUED5H4
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: external-dns
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions","networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: kube-system
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
      # If you're using kiam or kube2iam, specify the following annotation.
      # Otherwise, you may safely omit it.
#      annotations:
#        iam.amazonaws.com/role: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.7.6
        args:
        - --source=service
        - --source=ingress
#        - --domain-filter=external-dns-test.my-org.com # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=aws
#        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=shakti
      securityContext:
        fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token files

```
# Verify Deployment by checking logs 
kubectl apply -f external_dns.yml
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
# List pods (external-dns pod should be in running state) 
kubectl get pods
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
##### если в логах ошибки, пересоздай!
```

## Tests, check external-dns
** Change **test-qwe.company.com** to your domain!!!**
```
---
apiVersion: v1
kind: Service
metadata:
  name: test-svc
  annotations:
    external-dns.alpha.kubernetes.io/hostname: **test-qwe.company.com**
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    name: http
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: http
```
**you should see service load balancer with name - test-svc**
```
kubectl get svc
```
**если запись не создается**
надо удалить старую запись вручную

# k8s dashboard
First create fargrate profile
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml

#### Создаем ServiceAccount для кластера:

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: eks-admin
      namespace: kube-system
    ---
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: eks-admin
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: eks-admin
      namespace: kube-system
    EOF

#### Создаем ServiceAccount для входа в борду:

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: admin-user
      namespace: kubernetes-dashboard
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: admin-user
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: admin-user
      namespace: kubernetes-dashboard
    EOF
#### verify
    # change ClusterIP to type: NodePort
    export EDITOR=nano
    kubectl edit svc -n kubernetes-dashboard
    kubectl -n kubernetes-dashboard get pods
    kubectl get deployment metrics-server -n kube-system
    yum install jq -y
    aws eks get-token --cluster-name eksworkshop-eksctl | jq -r '.status.token'
    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

# Additional
### logs ingress
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
### get all zones
```
aws route53 list-hosted-zones-by-name
```

## 3.  logging
can be enabled on cluster gui page - configuration / logging
## 4. ExternalDNS checks
externaldns logs (check this actions with dns route53)
```
#kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
kubectl logs -n kube-system -f $(kubectl get po -n kube-system | egrep -o 'external-dns[A-Za-z0-9-]+')
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o 'aws-load-balancer-controller[a-zA-Z0-9-]+') 
```
### externaldns
dig echoserver.company.com
;; QUESTION SECTION:
;echoserver.josh-test-dns.com.  IN      A

;; ANSWER SECTION:
echoserver.josh-test-dns.com. 60 IN     A       13.59.147.105
echoserver.josh-test-dns.com. 60 IN     A       18.221.65.39
echoserver.josh-test-dns.com. 60 IN     A       52.15.186.25

curl echoserver.company.com

# ALB controller logs
# example with ExternalDNS
eksctl --region=us-west-1 --cluster qafgcluster create fargateprofile --name game-3048 --namespace game-3048
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: game-3048
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-3048
  name: "deployment-3048"
spec:
  selector:
    matchLabels:
      app: "app-3048"
  replicas: 1
  template:
    metadata:
      labels:
        app: "app-3048"
    spec:
      containers:
      - image: alexwhen/docker-2048
        imagePullPolicy: Always
        name: "app-3048"
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  namespace: game-3048
  name: "service-3048"
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: NodePort     # ! NODEPORT
  selector:
    app: "app-3048"
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: game-3048
  name: "ingress-3048"
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing # public service
    alb.ingress.kubernetes.io/target-type: ip  # ip, because FARGATE!
    #alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-1:ARM_ID:certificate/CERTIFICATE_ID  # for ssl add ARN or SSL CERT in AWS
  labels:
    app: "app-3048"
spec:
  rules:
    - host: 3048.company.com
      http:
        paths:
          - path: /* # redirect all request to here, maybe don't need
            backend:
              serviceName: "service-3048"
              servicePort: 80
              
```
#### how check
kubectl get all -n game-3048
kubectl get ingress -n game-3048
# можно проверить здесь, EC2/LOAD BALANCERS
https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#LoadBalancers:sort=loadBalancerName

# AWS Certificate Manager
Provision certificates
import certificates
Do the following:
For Certificate body, paste the PEM-encoded certificate to import.
For Certificate private key, paste the PEM-encoded, unencrypted private key that matches the certificate's public key.
(Optional) For Certificate chain, paste the PEM-encoded certificate chain.
Choose Review and import.
Review the information about your certificate, then choose Import

then copy ARN

# Restriction
Классические балансировщики нагрузки и балансировщики сетевой нагрузки можно использовать только с IP-целями. Вы также можете использовать балансировщики нагрузки приложений AWS с Fargate. Дополнительные сведения см. В разделах «Балансировщик нагрузки - IP-цели» и « Балансировка нагрузки приложений в Amazon EKS» .
Поды должны соответствовать профилю Fargate в то время, когда они запланированы для запуска на Fargate. Поды, не соответствующие профилю Fargate, могут застрять как файлы Pending. Если соответствующий профиль Fargate существует, вы можете удалить созданные вами ожидающие поды, чтобы перенести их в Fargate.
Демонсеты не поддерживаются в Fargate. Если вашему приложению требуется демон, вам следует перенастроить этот демон, чтобы он работал как дополнительный контейнер в ваших модулях.
Привилегированные контейнеры не поддерживаются в Fargate.



# PERSISTENT VOLUMES
## EBS
```
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/


curl https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/deploy/kubernetes/secret.yaml > secret.yaml
# Edit the secret with user credentials
kubectl apply -f secret.yaml



```
export EBS_CSI_POLICY_NAME="Amazon_EBS_CSI_Driver" cluster_name="api-dev" region="us-east-2"
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
