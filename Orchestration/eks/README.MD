
  
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

eksctl create cluster --name qa-fargate-cluster --region us-west 2 --version 1.18 --fargate

nano farget-cluster.yml

    ---
    apiVersion: eksctl.io/v1alpha5
    kind: ClusterConfig
    
    metadata:
      name: fargate-qa
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

    eksctl get clusters --region us-west-1

#### delete cluster

    eksctl delete cluster --region us-west-1 --name fargate-qa-cluster

### Create a Fargate pod execution role (Don't need, if create cluster with --fargate)
To create an AWS Fargate pod execution role with the AWS Management Console 
1. Open the IAM console at https://console.aws.amazon.com/iam/. 
2. Choose Roles, then Create role. 
3. Choose EKS from the list of services, EKS - Fargate pod for your use case, and then Next: Permissions. 
4. Choose Next: Tags. 
5. (Optional) Add metadata to the role by attaching tags as key–value pairs. For more information about using tags in IAM, see Tagging IAM Entities in the IAM User Guide. 
6. Choose Next: Review. 
7. For Role name, enter a unique name for your role, such as AmazonEKSFargatePodExecutionRole, then choose Create role

##  Step-02: Create & Associate IAM OIDC Provider for our EKS Cluster
### Step-02.1: Create an IAM policy for the service account 
**Note:** The ALB Ingress Controller requires several API calls to provision the ALB components for the ingress resource type. 
#### verify

    aws eks describe-cluster --region us-west-1 --name farget-qa --query "cluster.identity.oidc.issuer" --output text

Пример вывода:

    https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E

Так же можно проверить его тут:    
https://console.aws.amazon.com/iamv2/home?#/identity_providers
Перечислите поставщиков IAM  OIDC в своей учетной записи. Заменить <EXAMPLED539D4633E53DE1B716D3041E>(включая <>) значением, возвращенным предыдущей командой.

    aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>

Если результат возвращается предыдущей командой, значит, у вас уже есть провайдер для вашего кластера. Если выходные данные не возвращаются, необходимо создать поставщика IAM  OIDC.
Create an IAM OIDC identity provider for your cluster with the following command. Replace `<cluster_name>` (including `<>`) with your own value (allow the cluster to use AWS Identity and Access Management (IAM) for service accounts)

    eksctl utils associate-iam-oidc-provider --region us-west-1 --cluster farget-qa --approve
    
**Note:** The **FargateExecutionRole** is the role that the **kubelet** and **kube-proxy** run your Fargate pod on. However, it's not the role for the Fargate pod (that is, the **alb-ingress-controller**). For the Fargate pod, you must use the IAM role for the service account.


## Step-03:  policy creation
```
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json
```
```
aws --region=us-west-1 iam create-policy \
--policy-name ALBIngressControllerIAMPolicy \
--policy-document file://iam_policy.json
```

## Step-04: To create a service account, run the following command:
##### change cluster name (--cluster)
##### change --attach-policy-arn - IAM-policy-arn-created-in-step-3
<AWS_ACCOUNT_ID> get from step 3
policy

    eksctl create iamserviceaccount \
    --cluster=fargate-qa \
    --region=us-west-1 \
    --namespace=kube-system \
    --name=alb-ingress-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/<AWS_policy_name> \
    --override-existing-serviceaccounts \
    --approve
    
###### если выдает ошибку, что роль исключена или существует, https://console.aws.amazon.com/iam/home#/roles тут удаляем старые роли
eksctl create iamserviceaccount --region=us-west-2 --cluster=qafargate --namespace=kube-system --name=alb-ingress-controller --attach-policy-arn=<arn> --override-existing-serviceaccounts --approve
    
## Step-05: To verify that the new service role was created, run the following command:
#### --name iamserviceaccount - your-service-account-name
    eksctl get iamserviceaccount --region=us-west-2 --cluster=qafargate --name alb-ingress-controller --namespace kube-system

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
            - --cluster-name=qafargate    #<-- Add the cluster name
            - --aws-vpc-id=vpc-xxxxxxxxxxxxxxxxx    #<-- Add the VPC ID - can get on cluster network page
            - --aws-region=eu-west-2    #<-- Add the region 
            image: docker.io/amazon/aws-alb-ingress-controller:v1.1.4    #<======= Please make sure the Image is 1.1.4 and above. 
            imagePullPolicy: IfNotPresent

    kubectl apply -f alb-ingress-controller.yaml

## Step-02: To check the status of the  **alb-ingress-controller**  deployment, run the following command:
```
kubectl -n kube-system get pod
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

# k8s dashboard

First create fargrate profile

    eksctl create fargateprofile --cluster qafargate --name kubernetes-dashboard --namespace kubernetes-dashboard
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
    kubectl -n kubernetes-dashboard get pods
    kubectl get deployment metrics-server -n kube-system
    yum install jq -y
    aws eks get-token --cluster-name eksworkshop-eksctl | jq -r '.status.token'
    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')




## ExternalDNS
#### Used for Updating Route53 RecordSets from Kubernetes

https://www.stacksimplify.com/aws-eks/aws-alb-ingress/install-externaldns-on-aws-eks/
https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md

### create iam policy

Перейдите в Services -> IAM -> Policies -> Create Policy -> Json Tab -> paste json below
https://console.aws.amazon.com/iam/home#/policies$new?step=edit

 - [ ] Click on  **JSON**  Tab and copy paste below JSON
       -   Click on  **Visual editor**  tab to validate
       -   Click on  **Review Policy**
       -   **Name:**  AllowExternalDNSUpdates
       -   **Description:**  Allow access to Route53 Resources for ExternalDNS
       -   Click on  **Create Policy**

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


Запишите Политику ARN, которую мы будем использовать на следующем шаге.
arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates

### Create IAM Role, k8s Service Account & Associate IAM Policy
https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html
As part of this step, we are going to create a k8s Service Account named external-dns and also a AWS IAM role and associate them by annotating role ARN in Service Account.

In addition, we are also going to associate the AWS IAM Policy AllowExternalDNSUpdates to the newly created AWS IAM Role.

Create IAM Role, k8s Service Account & Associate IAM Policy

#### Replaced name, namespace, cluster, arn

    eksctl create iamserviceaccount \
    --name external-dns \
    --namespace default \
    --cluster qafargate \
    --attach-policy-arn arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates \
    --approve \
    --override-existing-serviceaccounts

##### Note!
--attach-policy-arn arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates  - можно взять IAM-POLICY-NAME-ARN ID

#### Verify the Service Account

    kubectl get sa external-dns

  ### Update External DNS Kubernetes manifest
  https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md

#### Change-1: Line number 9: IAM Role update[¶](https://www.stacksimplify.com/aws-eks/aws-alb-ingress/install-externaldns-on-aws-eks/#change-1-line-number-9-iam-role-update "Permanent link")
#### Chnage-2: Line 55, 56: Commented them

#### config
##### verify, rbac enabled or no
kubectl api-versions | grep rbac.authorization.k8s.io
nano rbac.yml

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: external-dns
      annotations:
        # Substitute your account ID and IAM service role name below.
    	eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME
    	eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME
    	eks.amazonaws.com/role-arn: arn:aws:iam::474660338267:policy/AllowExternalDNSUpdates
    ---
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: external-dns
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
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: external-dns
    subjects:
    - kind: ServiceAccount
      name: external-dns
      namespace: default
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: external-dns
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
            image: k8s.gcr.io/external-dns/external-dns:v0.7.3
            args:
            - --source=service
            - --source=ingress
    #        - --domain-filter=external-dns-test.my-org.com # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            - --provider=aws
    #        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
            - --registry=txt
            - --txt-owner-id=my-hostedzone-identifier
          securityContext:
            fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token files

    # Verify Deployment by checking logs 
    kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
    # List pods (external-dns pod should be in running state) 
    kubectl get pods


## FARGATE PROFILE

    # get profiles
    eksctl --cluster qafargate get fargateprofile
    # create new fargateprofile
    eksctl create fargateprofile --cluster qafargate --region us-west-2 --name shakti --namespace shakti
    # delete
    eksctl --cluster qafargate delete fargateprofile --name alb-sample-app

# deploy our app

    # app should be with namespace, what we defined in fargetprofile
    eksctl create fargateprofile --cluster qafargate --region us-west-2 --name shakti --namespace shakti
    aws eks --region us-west-2 update-kubeconfig --name qafargate 
    cp /root/.kube/configs/kubeconfig.yml /opt/.kube/configs/qa.yml
    export KUBECONFIG=$KUBECONFIG:/opt/.kube/configs/qa.yml
    kubectl get svc
    # then deploy your app - define namespace from fargetprofile and set limits!
    apiVersion: v1
    kind: pod
    metadata: 
      name: shakti
              resources:
                requests:
                  memory: "128Mi"
                  cpu: "500m"
                limits:
                  memory: "500Mi"
                  cpu: "1000m"    
