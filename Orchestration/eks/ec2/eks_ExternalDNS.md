
## ExternalDNS
### INSTALLATION with helm
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# AWS, ACCESSKEY & SECRETKEY
# go here and create ACCESS KEY
https://console.aws.amazon.com/iam/home?#/security_credentials
##
aws.credentials.accessKey	When using the AWS provider, set aws_access_key_id in the AWS credentials (optional)	""
aws.credentials.secretKey	When using the AWS provider, set aws_secret_access_key in the AWS credentials (optional)	""

# install (in values.yml change txt-owner)
export env=dev
cp values_qa.yaml values_prod.yaml
nano values_prod.yaml
helm upgrade --install apidns -f values_$env.yaml bitnami/external-dns --version 4.12.2

# CHECk
kubectl --namespace=default get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=apidns"
kubectl logs -f $(kubectl get po | egrep -o 'apidns-external-dns[A-Za-z0-9-]+')
```


















# OLD
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
# for delete
eksctl delete iamserviceaccount --name external-dns --region=$region --namespace default --cluster=$cluster_name
# for create
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
-   Change-2: Line 55, 56: Commented them (If you're using kiam or kube2iam.....annotations:)
-   Change-3: comment line with: --domain-filter=external-dns-test.my-org.com
-   Change-4: comment line with: --policy=upsert-only

**config**
!! verify, rbac enabled or no
- first we create policy
- copy policy arn
- attach policy arn to SA, then we create
```
kubectl api-versions | grep rbac.authorization.k8s.io
nano external_dns.yml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
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

# error
failed to sync cache: timed out waiting for the condition
solution:
use namespace: only default !

```
# Verify Deployment by checking logs, List pods (external-dns pod should be in running state) 
```
kubectl apply -f external_dns.yml
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+') 
#kubectl logs -n kube-system -f $(kubectl get po -n kube-system | egrep -o 'external-dns[A-Za-z0-9-]+')
#kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o 'aws-load-balancer-controller[a-zA-Z0-9-]+') 
kubectl get pods
##### если в логах ошибки, пересоздай!
```
### get all zones
```
aws route53 list-hosted-zones-by-name
```
## 3.  logging
can be enabled on cluster gui page - configuration / logging
### externaldns
dig echoserver.company.com
;; QUESTION SECTION:
;echoserver.josh-test-dns.com.  IN      A

;; ANSWER SECTION:
echoserver.josh-test-dns.com. 60 IN     A       13.59.147.105
echoserver.josh-test-dns.com. 60 IN     A       18.221.65.39
echoserver.josh-test-dns.com. 60 IN     A       52.15.186.25

curl echoserver.company.com
```
# ================================================================
# EXAMPLES:
# ================================================================
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




## Tests, check external-dns 2, with SERVICE ONLY
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
