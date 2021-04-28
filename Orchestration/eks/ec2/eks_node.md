
 - [Install tool](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-01-install-eksctl)
 - [Create cluster](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-02-create-cluster)
 - [Create & Associate IAM OIDC Provider for our EKS Cluster](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-03-create--associate-iam-oidc-provider-for-our-eks-cluster)
 - [IAM policy for AWS ALB](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-04--iam-policy-for-the-aws-load-balancer-controller)
 - [IAM role](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-05--create-a-iam-role-and-serviceaccount-for-the-load-balancer-controller-use-the-arn-from-the-step-above)
 - [AWS ALB deployment](https://github.com/allanian/docker/tree/master/Orchestration/eks#step-06-install-aws-load-balancer-controller)
 - 

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


