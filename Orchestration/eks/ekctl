https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
## Step-01: Create EKS Cluster using eksctl

#### Create Cluster

    eksctl create cluster \
    --name qa \
    --tags name=qa \
    --version 1.18 \
    --region us-west-2 \
    --fargate

#### Get List of clusters

    eksctl get clusters

#### delete cluster

    eksctl delete cluster --name QA

##  Step-02: Create & Associate IAM OIDC Provider for our EKS Cluster
To allow the cluster to use AWS Identity and Access Management (IAM) for service accounts, run the following command:

    eksctl utils associate-iam-oidc-provider --region us-west-2 --cluster QA --approve
    
**Note:** The **FargateExecutionRole** is the role that the **kubelet** and **kube-proxy** run your Fargate pod on. However, it's not the role for the Fargate pod (that is, the **alb-ingress-controller**). For the Fargate pod, you must use the IAM role for the service account.


## Step-03: Create an IAM policy for the service account 
using the correct [permissions](https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json) from the Kubernetes GitHub website. Note the Amazon Resource Name (ARN) of the IAM policy.
**Note:** The ALB Ingress Controller requires several API calls to provision the ALB components for the ingress resource type.

    aws eks describe-cluster --name qa--query "cluster.identity.oidc.issuer" --output text

Пример вывода:

    https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E

Перечислите поставщиков IAM  OIDC в своей учетной записи. Заменить <EXAMPLED539D4633E53DE1B716D3041E>(включая <>) значением, возвращенным предыдущей командой.

    aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>

Если результат возвращается предыдущей командой, значит, у вас уже есть провайдер для вашего кластера. Если выходные данные не возвращаются, необходимо создать поставщика IAM  OIDC.

5.2) Загрузите политику IAM для контроллера AWS  Load  Balancer  Controller, которая позволяет ему выполнять вызовы API  AWS от вашего имени. Вы можете просмотреть документ политикина GitHub. Используйте команду, соответствующую региону, в котором находится ваш кластер.

    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.0/docs/install/iam_policy.json

5.3) Создайте политику IAM, используя политику, загруженную на предыдущем шаге.

    aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

    "Policy": {
    "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
    "PolicyId": "ANPAW5A7V7JN6WDOU7MYK",
    "Arn": "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy",
    "Path": "/",
    "DefaultVersionId": "v1",
    "AttachmentCount": 0,
    "PermissionsBoundaryUsageCount": 0,
    "IsAttachable": true,
    "CreateDate": "2021-01-26T06:26:00+00:00",
    "UpdateDate": "2021-01-26T06:26:00+00:00"

## Step-04: To create a service account, run the following command:
##### change cluster name (--cluster)
##### change --attach-policy-arn - IAM-policy-arn-created-in-step-3

    eksctl create iamserviceaccount \
    --cluster=qa \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

## Step-05: To verify that the new service role was created, run the following command:

    eksctl get iamserviceaccount --cluster QA --name iamserviceaccount --namespace kube-system

**Note:** The role name begins with **eksctl-your-cluster-name-addon-iamserviceaccount-**.

## Step-06:  To create RBAC permissions and a service account for the ALB Ingress Controller, run the following command:

    $ curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

7. Open the **rbac-role.yaml** file in a text editor, and then remove the **ServiceAccount** section because it was already created in step 4:

apiVersion: v1 kind: ServiceAccount metadata: labels: app.kubernetes.io/name: alb-ingress-controller name: alb-ingress-controller namespace: kube-system ...
