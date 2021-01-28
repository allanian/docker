
  
https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
# Create an Amazon EKS cluster, service account policy, and RBAC policies
## Step-01: Create EKS Cluster using eksctl

#### Create Cluster
--tags name=qa
--region us-west-1 - California
--region us-west-2 - Oregon

    eksctl create cluster \
    --name qa \
    --tags name=qa \
    --version 1.18 \
    --region us-west-1 \
    --fargate

nano farget-cluster.yml

    ---
    apiVersion: eksctl.io/v1alpha5
    kind: ClusterConfig
    
    metadata:
      name: fargate-cluster-qa
      region: us-west-2
    
    fargateProfiles:
      - name: fp-default
        selectors:
          # All workloads in the "default" Kubernetes namespace will be
          # scheduled onto Fargate:
          - namespace: default
          # All workloads in the "kube-system" Kubernetes namespace will be
          # scheduled onto Fargate:
          - namespace: kube-system
      - name: fp-shakti
        selectors:
          # All workloads in the "shakti" Kubernetes namespace matching the following
          # label selectors will be scheduled onto Fargate:
          - namespace: shakti
          #  labels:
          #    env: dev
          #    checks: passed
      
    eksctl create cluster -f farget-cluster.yml


#### Get List of clusters

    eksctl get clusters

#### delete cluster

    eksctl delete cluster --name fargate-cluster-qa

##  Step-02: Create & Associate IAM OIDC Provider for our EKS Cluster
To allow the cluster to use AWS Identity and Access Management (IAM) for service accounts, run the following command:

    eksctl utils associate-iam-oidc-provider --region us-west-2 --cluster QA --approve
    
**Note:** The **FargateExecutionRole** is the role that the **kubelet** and **kube-proxy** run your Fargate pod on. However, it's not the role for the Fargate pod (that is, the **alb-ingress-controller**). For the Fargate pod, you must use the IAM role for the service account.


## Step-03: Create an IAM policy for the service account 
**Note:** The ALB Ingress Controller requires several API calls to provision the ALB components for the ingress resource type.

    aws eks describe-cluster --name fargate-cluster-qa --query "cluster.identity.oidc.issuer" --output text

Пример вывода:

    https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E

Так же можно проверить его тут:    
https://console.aws.amazon.com/iamv2/home?#/identity_providers
Перечислите поставщиков IAM  OIDC в своей учетной записи. Заменить <EXAMPLED539D4633E53DE1B716D3041E>(включая <>) значением, возвращенным предыдущей командой.

    aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>

Если результат возвращается предыдущей командой, значит, у вас уже есть провайдер для вашего кластера. Если выходные данные не возвращаются, необходимо создать поставщика IAM  OIDC.

### policy creation
```
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json
```
```
aws --region=us-west-2 iam create-policy \
--policy-name ALBIngressControllerIAMPolicy \
--policy-document file://iam_policy.json
```

## Step-04: To create a service account, run the following command:
##### change cluster name (--cluster)
##### change --attach-policy-arn - IAM-policy-arn-created-in-step-3
<AWS_ACCOUNT_ID> get from step 3
policy

    eksctl create iamserviceaccount \
    --cluster=fargate-cluster-qa \
    --namespace=kube-system \
    --name=alb-ingress-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/<AWS_policy_name> \
    --override-existing-serviceaccounts \
    --approve
    
## Step-05: To verify that the new service role was created, run the following command:
#### --name iamserviceaccount - your-service-account-name
    eksctl get iamserviceaccount --cluster fargate-cluster-qa --name alb-ingress-controller --namespace kube-system

**Note:** The role name begins with **eksctl-your-cluster-name-addon-iamserviceaccount-**.

## Step-06: To create RBAC permissions and a service account for the ALB Ingress Controller, run the following command:

    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

## Step-07:  Open the **rbac-role.yaml** file in a text editor, and then remove the **ServiceAccount** section because it was already created in step 4:

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      labels:
        app.kubernetes.io/name: alb-ingress-controller
      name: alb-ingress-controller
      namespace: kube-system
    ...

    kubectl apply -f rbac-role.yaml

# Set up the ALB Ingress Controller

## Step-01: To download the YAML file for the controller, run the following command:
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
#### Open the **alb-ingress-controller.yaml** file in a text editor, and then make the following changes:
    nano alb-ingress-controller.yaml
    spec:
          containers:
          - args:
            - --ingress-class=alb
            - --cluster-name=fargate-cluster-qa    #<-- Add the cluster name
            - --aws-vpc-id=vpc-xxxxxxxxxxxxxxxxx    #<-- Add the VPC ID - can get on cluster network page
            - --aws-region=eu-west-2    #<-- Add the region 
            image: docker.io/amazon/aws-alb-ingress-controller:v1.1.4    #<======= Please make sure the Image is 1.1.4 and above. 
            imagePullPolicy: IfNotPresent

    kubectl apply -f alb-ingress-controller.yaml

## Step-02: To check the status of the  **alb-ingress-controller**  deployment, run the following command:
```
kubectl rollout status deployment alb-ingress-controller -n kube-system
```
## Step-03: Test the ALB Ingress Controller

    eksctl create fargateprofile --namespace 2048-game --cluster your-cluster-name
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-ingress.yaml
Open the  **2048-ingress**  file in a text editor, and then make the following changes to the annotations:

```plainText
annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip                       # Add this annotation
    alb.ingress.kubernetes.io/security-groups: your-security-group  # Custom security group
```

**Note:**  The ALB Ingress Controller works only in the IP mode on Amazon EKS for Fargate. For more information, see  [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/annotations/)  on the AWS ALB Ingress Controller website.

To apply the files for the test deployment, run the following commands:

```plainText
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-namespace.yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-deployment.yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/2048/2048-service.yaml
$ kubectl apply -f 2048-ingress.yaml
```

5. To see the 2048 page using the address that you receive, run the following command:

```plainText
$ kubectl get ingress/2048-ingress -n 2048-game
```

The command output should have the load balancer's fully qualified domain name (FQDN) that you can access from a web browser.



### Troubleshoot the ALB Ingress Controller

If you have issues setting up the ALB Ingress Controller, run the following commands:

```plainText
$ kubectl logs your-alb-ingress-controller -n kube-system
$ kubectl get endpoints -A
$ kubectl get ingress/2048-ingress -n 2048-game
```

The output from the  **logs**  command returns error messages (for example, with tags or subnets) that can help you troubleshoot  [common errors](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/issues) (from the Kubernetes GitHub website). The  **get endpoints**  and  **get ingress**  commands can show you ingress resources that aren't deployed successfully.

If you run the YAML file for the ALB Ingress Controller without changing the image to 1.1.4, then you receive an error stating that the ALB Ingress Controller is unable to find the instance ID. To resolve this error, see  [aws-alb-ingress-controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/commit/4d1f94caa146a79f662ce66f7cabfdf0d355ac69#diff-0e2522e4ac7bdfb6c24a6093a6e09cea)  on the Kubernetes GitHub website.

**Note:**  The image 1.1.3v has the configurations to check for the network interface of your Amazon Elastic Compute Cloud (Amazon EC2) instance. To enable the ALB Ingress Controller to run on Fargate, the image code is changed to find the associated elastic network interfaces instead of the Amazon EC2 worker nodes.
