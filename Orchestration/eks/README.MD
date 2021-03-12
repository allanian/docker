
  
https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
# Create an Amazon EKS cluster, service account policy, and RBAC policies
## Step-01: Create EKS Cluster using eksctl

#### install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/bin
eksctl version

#### Create Cluster
--region us-west-1 - California
--region us-west-2 - Oregon

eksctl create cluster --name qafgcluster --region us-west-1 --version 1.18 --fargate
#### or you can create from file:
nano farget-cluster.yml

    ---
    apiVersion: eksctl.io/v1alpha5
    kind: ClusterConfig
    
    metadata:
      name: fargate-qa
      region: us-west-2
      version: '1.18'
    iam:
      withOIDC: true
    fargateProfiles:
      - name: fp-default
        selectors:
          # All workloads in the "default" Kubernetes namespace will be
          # scheduled onto Fargate:
          - namespace: default
          # All workloads in the "kube-system" Kubernetes namespace will be
          # scheduled onto Fargate:
          - namespace: kube-system
      - name: fp-developers
        selectors:
          # All workloads in the "developer" Kubernetes namespace matching the following
          # label selectors will be scheduled onto Fargate:
          - namespace: developers
          #  labels:
          #    env: dev
          #    checks: passed
    cloudWatch:
      clusterLogging:
        enableTypes: ["*"]

    eksctl create cluster -f farget-cluster.yml


#### Get List of clusters

    eksctl --region us-west-2 get clusters 
    aws eks --region us-west-1 update-kubeconfig --name qafgcluster
    cp /root/.kube/configs/kubeconfig.yml /opt/.kube/configs/qa.yml
    export KUBECONFIG=$KUBECONFIG:/opt/.kube/configs/qa.yml
    kubectl get svc

#### delete cluster

    eksctl --region us-west-2 delete cluster --name qafargate 

### Create a Fargate pod execution role (Don't need, if create cluster with --fargate)
It's created auto for cluster type - fargate
##  Step-02: Create & Associate IAM OIDC Provider for our EKS Cluster
### Step-02.1: Create an IAM policy for the service account 
**Note:** The ALB Ingress Controller requires several API calls to provision the ALB components for the ingress resource type. 
#### verify

    aws eks describe-cluster --region us-west-1 --name qafgcluster --query "cluster.identity.oidc.issuer" --output text

Пример вывода:

    https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E

Так же можно проверить его тут:    
https://console.aws.amazon.com/iamv2/home?#/identity_providers
Перечислите поставщиков IAM  OIDC в своей учетной записи. Заменить <EXAMPLED539D4633E53DE1B716D3041E>(включая <>) значением, возвращенным предыдущей командой.

    aws iam list-open-id-connect-providers | grep <EXAMPLED539D4633E53DE1B716D3041E>

Если результат возвращается предыдущей командой, значит, у вас уже есть провайдер для вашего кластера. Если выходные данные не возвращаются, необходимо создать поставщика IAM  OIDC.
Create an IAM OIDC identity provider for your cluster with the following command. Replace `<cluster_name>` (including `<>`) with your own value (allow the cluster to use AWS Identity and Access Management (IAM) for service accounts)

    eksctl utils associate-iam-oidc-provider --region us-west-1 --cluster qafgcluster --approve
    
**Note:** The **FargateExecutionRole** is the role that the **kubelet** and **kube-proxy** run your Fargate pod on. However, it's not the role for the Fargate pod (that is, the **alb-ingress-controller**). For the Fargate pod, you must use the IAM role for the service account.



## STEP 02:  IAM policy for the AWS Load Balancer Controller
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```
```
aws iam create-policy \
--region=us-west-1 \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam-policy.json
```
## STEP 03:  Create a IAM role and ServiceAccount for the Load Balancer controller, use the ARN from the step above
    eksctl create iamserviceaccount \
    --cluster=qafgcluster \
    --region=us-west-1 \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<ARN_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

####  To verify that the new service role was created, run the following command:
    eksctl get iamserviceaccount --region=us-west-1 --cluster=qafgcluster --namespace kube-system

**Note:** The role name begins with **eksctl-your-cluster-name-addon-iamserviceaccount-**.

## Step-04: Install aws-load-balancer-controller

    #Add the EKS repository to Helm:
    helm repo add eks https://aws.github.io/eks-charts
    #Install the TargetGroupBinding CRDs:
    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    
    # Install the AWS Load Balancer controller, if using iamserviceaccount
    helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
    --set clusterName=qafgcluster \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set vpcId=vpc-00756875232f0fc37 \
    --set region=us-west-1
  Options
  https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
  
#### uninstall
helm delete aws-load-balancer-controller
####  To check the status of the  **alb-ingress-controller**  deployment, run the following command:

kubectl -n kube-system get pod

EXAMPLE for check AWX-LB-controller
eksctl --region=us-west-1 --cluster qafgcluster create fargateprofile --name game-2048 --namespace game-2048
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
apiVersion: extensions/v1beta1
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
            backend:
              serviceName: service-2048
              servicePort: 80
```

kubectl get ingress -n game-2048
copy ADDRESS and paste to Browser

## ExternalDNS
#### Used for Updating Route53 RecordSets from Kubernetes

 - [ ] 1. create iam policy, copy ID
 - [ ] 2. create iam role and attach policy ID
 - [ ] 3. create service account in k8s and attach role ID 

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
In addition, we are also going to associate the AWS IAM Policy AllowExternalDNSUpdates to the newly created AWS IAM Role.

Create IAM Role, k8s Service Account & Associate IAM Policy

#### Replaced name, namespace, cluster, arn

    eksctl create iamserviceaccount \
    --name external-dns \
    --region=us-west-1 \
    --namespace default \
    --cluster qafgcluster \
    --attach-policy-arn arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates \
    --approve \
    --override-existing-serviceaccounts

##### Note!
--attach-policy-arn arn:aws:iam::180789647333:policy/AllowExternalDNSUpdates  - используем ARM c iam policy for route53 - AllowExternalDNSUpdates:
https://console.aws.amazon.com/iam/home#/policies
IAM=>POLICY=>NAME=>ARN ID


#### Verify the Service Account

    kubectl get sa external-dns

  ### Update External DNS Kubernetes manifest
  https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
## how find role-arn
### Verify CloudFormation Stack

-   Go to Services -> CloudFormation
-   Verify the latest CFN Stack created. `eksctl` external-dns
-   Click on  **Resources**  tab
-   Click on link in  **Physical ID**  field which will take us to  **IAM Role**  directly

### Verify IAM Role & IAM Policy

-   With above step in CFN, we will be landed in IAM Role created for external-dns.
-   Verify in  **Permissions**  tab we have a policy named  **AllowExternalDNSUpdates**
-   Now make a note of that Role ARN, this we need to update in External-DNS k8s manifest Копируем ARN роли:
```
    arn:aws:iam::180789647333:role/eksctl-eksdemo1-addon-iamserviceaccount-defa-Role1-1O3H7ZLUED5H4
```
#### Change-1: Line number 9: IAM Role update[¶](https://www.stacksimplify.com/aws-eks/aws-alb-ingress/install-externaldns-on-aws-eks/#change-1-line-number-9-iam-role-update "Permanent link")
#### Chnage-2: Line 55, 56: Commented them

#### config
### verify, rbac enabled or no
##### first we create policy, copy policy arn, attach policy arn to SA, then we create
kubectl api-versions | grep rbac.authorization.k8s.io
nano rbac.yml
```
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: external-dns
      annotations:
        # paster Role ARN
        eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME
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
    #        - --policy=upsert-only # comment for allow deleting any records ExternalDNS, uncomment to enable full synchronization
            - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
            - --registry=txt
            - --txt-owner-id=my-hostedzone-identifier
          securityContext:
            fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token files
```
```
    # Verify Deployment by checking logs 
    kubectl apply -f rbac.yml
    kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
    # List pods (external-dns pod should be in running state) 
    kubectl get pods
    kubectl logs external-dns-57d774cd5c-wtd6d
    ##### если в логах ошибки, пересоздай!
```

# Example external-dns
## service
```
---
apiVersion: v1
kind: Service
metadata:
  name: test-svc
  annotations:
    external-dns.alpha.kubernetes.io/hostname: test-qwe.company.com
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
# you should see service load balancer with name - test-svc
kubectl get svc

# если запись не создается 
надо удалить старую запись вручную


# k8s dashboard
First create fargrate profile

    eksctl create fargateprofile --region=us-west-1 --cluster qafgcluster --name kubernetes-dashboard --namespace kubernetes-dashboard
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

## FARGATE PROFILE

    # get profiles
    eksctl --region=us-west-1 --cluster qafgcluster get fargateprofile
    # create new fargateprofile
    eksctl create fargateprofile --cluster CLUSTER_NAME --region REGION_CODE --name PROFILE_NAME --namespace NAMESPACE_NAME
    # delete
    eksctl --cluster qafargate delete fargateprofile --name alb-sample-app

# deploy our app

    # app should be with namespace, what we defined in fargetprofile
    eksctl --region=us-west-1 --cluster qafgcluster create fargateprofile --name developers --namespace developers
    # then deploy your app - define namespace from fargetprofile and set limits!

              resources:
                requests:
                  memory: "128Mi"
                  cpu: "500m"
                limits:
                  memory: "500Mi"
                  cpu: "1000m"    

### create dns records - route53 - from ingress
on ingress, set this
### logs ingress
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
### get all zones

aws route53 list-hosted-zones-by-name


# logging
can be enabled on cluster gui page - configuration / logging
# externaldns logs (check this actions with dns route53)
kubectl logs external-dns-57d774cd5c-wtd6d -f
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o 'aws-load-balancer-controller[a-zA-Z0-9-]+') 
# externaldns
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
