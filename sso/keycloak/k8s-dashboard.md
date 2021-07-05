# K8s SSO with Keycloak
## 1. Keycloak 
### 0.0. DEPENDENCIES
### 0.0.1 Create a realm
- Create realm company
### 0.0.2. Configure LDAP from ldap.md
### 0.0.3. Create groups in AD
```
kubernetes-reader/kubernetes-admin
```
### 0.0.4 Mapper ldap groups
**User federation --> ldap --> Mappers --> Create**
| Option | Value | Description |
| ------ | ------ | ------ |
| Name| groups |
| Mapper type | group-ldap-mapper |
| LDAP group DN | OU=Users,DC=company,DC=ru |
| Group Name LDAP Attribute | cn |
| Group Object Classes | group |
| Preserve Group Inheritance | ON |
| Ignore Missing Groups | ON | maybe ON help to import|
| Membership LDAP Attribute | member |
| Membership Attribute Type | DN |
| Membership User LDAP Attribute | sAMAccountName |
| Mode | READ_ONLY |
| User Groups Retrieve Strategy | GET_GROUPS_FROM_USER_MEMBEROF_ATTRIBUTE |

### 1.1. Create a client
Click Keycloak=>Clients=>Create
| Option | Value |
| ------ | ------ |
| Client ID | kubernetes |
| Client Protocol | openidc |
Click "Save".

Configure the client
| Option | Value | Description|
| ------ | ------ | ------ |
| Client ID | kubernetes | any name for client |
| Name | kubernetes | any name for client |
| Description | kubernetes-dashboard sso | Description |
| Client Protocol | openid-connect | client protocol (saml/openid) |
| Acess type | confidential | client required Secret! |
| Standard Flow Enabled | ON |
| Implicit Flow Enabled | OFF |
| Direct Access Grants Enabled | ON |
| Service Accounts Enabled| ON |
| OAuth 2.0 Device Authorization Grant Enabled | OFF |
| Authorization Enabled | ON |
| Root URL | https://k8s.company.ru/ | address dashboard k8s |
| Valid Redirect URIs | https://k8s.company.ru/oauth/callback/* |
| Admin URL | https://k8s.company.ru/ |
| Web Origins | https://k8s.company.ru/ |
Leave the rest as they are.

### 1.2. Создадим scope для групп:  
**Client Scopes --> Create**
| Option | Value | Description|
| ------ | ------ | ------ |
| Name | group | name for mapper |
| Protocol | openid-connect |  |
| Display On Consent Screen | ON | |
| Include In Token Scope | ON | |


### 1.3. настроим mapper для них:  
**Client Scopes --> groups --> Mappers --> Create**
| Option | Value | Description|
| ------ | ------ | ------ |
| Protocol| openid-connect | name for mapper |
| Name | groups |  |
| Mapper Type | Group Membership | |
| Token Claim Name | groups | |
| Full group path | OFF |  |

### 1.4. Добавляем маппинг наших групп в Default Client Scopes:  
  
**Clients --> kubernetes --> Client Scopes --> Default Client Scopes**  
Выбираем **groups** в **Available Client Scopes**, нажимаем **Add selected**  
Теперь настроим аутентификацию нашего приложения, переходим:
**Clients**  -->  **kubernetes**
| Option | Value | Description|
| ------ | ------ | ------ |
| **Authorization Enabled**| ON |
```
Нажимем  **save**  и на этом настройка клиента завершена, теперь на вкладке
**Clients**  -->  **kubernetes**  -->  **Credentials**
вы сможете получить  **Secret**  который мы будем использовать в дальнейшем.
```
### 1.5. Configure the client mappers - MAYBE DONT NEED
client=>mappers=>create
#### group
| Option | Value | Description|
| ------ | ------ | ------ |
| Name | groups | name for mapper |
| Mapper Type | Group Membership | don't include full path |
| Token Claim Name | groups | name for claim |
| Full group path | Off |  |
#### audience
| Option | Value | Description|
| ------ | ------ | ------ |
| Name | audience | name for mapper |
| Mapper Type | Audience |  |
| Included Client Audience | kubernetes | |
| Add to ID tokenh | Off | |
| Add to access token | On| |

# K8s Apiserver
```
nano /etc/kubernetes/manifests/kube-apiserver.yaml
    - --advertise-address=10.3.3.215
    # paste it
    - --oidc-issuer-url=https://keycloak.company.ru/auth/realms/company
    - --oidc-client-id=kubernetes
    - --oidc-username-claim=email
    - --oidc-groups-claim=groups

Обновляем kubeadm конфиг в кластере:
kubectl edit -n kube-system configmaps kubeadm-config
```
apiVersion: v1
data:
  ClusterConfiguration: |
    apiServer:
      extraArgs:
        oidc-issuer-url: https://keycloak.company.ru/auth/realms/company
        oidc-client-id: kubernetes
        oidc-username-claim: email
        oidc-groups-claim: groups
        authorization-mode: Node,RBAC
      timeoutForControlPlane: 4m0s

```
systemctl restart docker
```




# K8s dashboard
```
# for delete
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
# for install
kubectl create ns kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
kubectl -n keycloak-gatekeeper create secret tls tls-cert --key ./1.key --cert ./1.cer
```
nano values.yaml
```
image:
  repository: kubernetesui/dashboard
  tag: v2.2.0
  pullPolicy: IfNotPresent
  pullSecrets: []

replicaCount: 1

## Here annotations can be added to the kubernetes dashboard deployment
annotations: {}
## Here labels can be added to the kubernetes dashboard deployment
labels: {}

## Additional container arguments
##
extraArgs:
#   - --enable-skip-login
  - --enable-insecure-login
#   - --system-banner="Welcome to Kubernetes"

## Additional container environment variables
##
extraEnv: []
# - name: SOME_VAR
#   value: 'some value'

## Additional volumes to be added to kubernetes dashboard pods
##
extraVolumes: []
# - name: dashboard-kubeconfig
#   secret:
#     defaultMode: 420
#     secretName: dashboard-kubeconfig

## Additional volumeMounts to be added to kubernetes dashboard pods
##
extraVolumeMounts: []
# - mountPath: /kubeconfig
#   name: dashboard-kubeconfig
#   readOnly: true

# Annotations to be added to kubernetes dashboard pods
podAnnotations:
  seccomp.security.alpha.kubernetes.io/pod: 'runtime/default'

# Labels to be added to kubernetes dashboard pods
podLabels: {}

## Node labels for pod assignment
## Ref: https://kubernetes.io/docs/user-guide/node-selection/
##
nodeSelector: {}

## List of node taints to tolerate (requires Kubernetes >= 1.6)
tolerations: []
#  - key: "key"
#    operator: "Equal|Exists"
#    value: "value"
#    effect: "NoSchedule|PreferNoSchedule|NoExecute"

## Affinity
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
affinity: {}

# priorityClassName: ""

resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 2
    memory: 200Mi

## Serve application over HTTP without TLS
##
## Note: If set to true, you may want to add --enable-insecure-login to extraArgs
protocolHttp: false

service:
  type: ClusterIP
  externalPort: 443

  # LoadBalancerSourcesRange is a list of allowed CIDR values, which are combined with ServicePort to
  # set allowed inbound rules on the security group assigned to the master load balancer
  # loadBalancerSourceRanges: []

  ## Additional Kubernetes Dashboard Service annotations
  annotations: {}

  ## Here labels can be added to the Kubernetes Dashboard service
  labels: {}

  ## set a specific load balancer Ip if you're using one
  # loadBalancerIP:

  ## Enable or disable the kubernetes.io/cluster-service label. Should be disabled for GKE clusters >=1.15.
  ## Otherwise, the addon manager will presume ownership of the service and try to delete it.
  clusterServiceLabel:
    enabled: true
    key: "kubernetes.io/cluster-service"

ingress:
  ## If true, Kubernetes Dashboard Ingress will be created.
  ##
  enabled: true

  ## Kubernetes Dashboard Ingress annotations
  ##
  ## Add custom labels
  # labels:
  #   key: value
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: 'true'
    #nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    #nginx.ingress.kubernetes.io/ssl-redirect: 'true'
    #nginx.ingress.kubernetes.io/use-port-in-redirects: 'true'
  ## If you plan to use TLS backend with enableInsecureLogin set to false
  ## (default), you need to uncomment the below.
  ## If you use ingress-nginx < 0.21.0
  #   nginx.ingress.kubernetes.io/secure-backends: "true"
  ## if you use ingress-nginx >= 0.21.0
  #   nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"


  ## Kubernetes Dashboard Ingress paths
  ##
  paths:
    - /
  #  - /*

  ## Custom Kubernetes Dashboard Ingress paths. Will override default paths.
  ##
  customPaths: []
  #  - backend:
  #      serviceName: ssl-redirect
  #      servicePort: use-annotation
  #  - backend:
  #      serviceName: >-
  #        {{ include "kubernetes-dashboard.fullname" . }}
  #      # Don't use string here, use only integer value!
  #      servicePort: 443

  ## Kubernetes Dashboard Ingress hostnames
  ## Must be provided if Ingress is enabled
  ##
  hosts:
    - dash-k8s.company.ru


  ## Kubernetes Dashboard Ingress TLS configuration
  ## Secrets must be manually created in the namespace
  ##
#  tls:
#    - secretName: tls-cert
#      hosts:
#        - dash-test.company.ru

settings: {}
  ## Cluster name that appears in the browser window title if it is set
  # clusterName: ""
  ## Max number of items that can be displayed on each list page
  # itemsPerPage: 10
  ## Number of seconds between every auto-refresh of logs
  # logsAutoRefreshTimeInterval: 5
  ## Number of seconds between every auto-refresh of every resource. Set 0 to disable
  # resourceAutoRefreshTimeInterval: 5
  ## Hide all access denied warnings in the notification panel
  # disableAccessDeniedNotifications: false

## Pinned CRDs that will be displayed in dashboard's menu
pinnedCRDs: []
  # - kind: customresourcedefinition
  ##  Fully qualified name of a CRD
  #   name: prometheuses.monitoring.coreos.com
  ##  Display name
  #   displayName: Prometheus
  ##  Is this CRD namespaced?
  #   namespaced: true

## Metrics Scraper
## Container to scrape, store, and retrieve a window of time from the Metrics Server.
## refs: https://github.com/kubernetes-sigs/dashboard-metrics-scraper
metricsScraper:
  enabled: true
  image:
    repository: kubernetesui/metrics-scraper
    tag: v1.0.6
  resources: {}
  ## SecurityContext for the metrics scraper container
  containerSecurityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    runAsUser: 1001
    runAsGroup: 2001
#  args:
#    - --logtostderr=true
#    - --v=0

## Optional Metrics Server sub-chart
## Enable this is you don't already have metrics-server enabled on your cluster and
## want to use it with dashboard metrics-scraper
## refs:
##  - https://hub.helm.sh/charts/stable/metrics-server
##  - https://github.com/kubernetes-sigs/metrics-server
metrics-server:
  enabled: true
  args:
  - --kubelet-preferred-address-types=InternalIP
  - --kubelet-insecure-tls


rbac:
  # Specifies whether namespaced RBAC resources (Role, Rolebinding) should be created
  create: true

  # Specifies whether cluster-wide RBAC resources (ClusterRole, ClusterRolebinding) to access metrics should be created
  # Independent from rbac.create parameter.
  clusterRoleMetrics: true

  # Start in ReadOnly mode.
  # Only dashboard-related Secrets and ConfigMaps will still be available for writing.
  #
  # The basic idea of the clusterReadOnlyRole
  # is not to hide all the secrets and sensitive data but more
  # to avoid accidental changes in the cluster outside the standard CI/CD.
  #
  # It is NOT RECOMMENDED to use this version in production.
  # Instead you should review the role and remove all potentially sensitive parts such as
  # access to persistentvolumes, pods/log etc.
  #
  # Independent from rbac.create parameter.
  clusterReadOnlyRole: false

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name:

livenessProbe:
  # Number of seconds to wait before sending first probe
  initialDelaySeconds: 30
  # Number of seconds to wait for probe response
  timeoutSeconds: 30

## podDisruptionBudget
## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
podDisruptionBudget:
  enabled: false
  minAvailable:
  maxUnavailable:

## PodSecurityContext for pod level securityContext
# securityContext:
#   runAsUser: 1001
#   runAsGroup: 2001

## SecurityContext for the kubernetes dashboard container
containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsUser: 1001
  runAsGroup: 2001

networkPolicy:
  enabled: false

## podSecurityPolicy for fine-grained authorization of pod creation and updates
podSecurityPolicy:
  # Specifies whether a pod security policy should be created
  enabled: false

```
```
helm upgrade --install kubernetes-dashboard -n kubernetes-dashboard -f dashb.yml kubernetes-dashboard/kubernetes-dashboard
```
# RBAC
```
### ADMIN Access
kubectl apply -f rbac.yaml
group kubernetes-admin/kubernetes-reader should be exist in Keycloak!
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: keycloak-admin-group
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: kubernetes-admin



# USER
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: keycloak-reader-role
  namespace: kubernetes-dashboard
rules:
# see all infra
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
# get access to pod logs
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
# get access to pod exec
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: keycloak-reader-group
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: keycloak-reader-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: kubernetes-reader
```

# Gatekeeper
```
kubectl create ns keycloak-gatekeeper
kubectl -n keycloak-gatekeeper create secret tls tls-cert --key ./1.key --cert ./1.cer
nano values.yaml
```
```
# Включаем ingress
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  path: /
  hosts:
    - k8s.company.ru
  tls:
   - secretName: tls-cert
     hosts:
       - k8st.company.ru

# Говорим где мы будем авторизовываться у OIDC провайдера
discoveryURL: "https://keycloak.company.ru/auth/realms/company"
# Имя клиента которого мы создали в Keycloak
ClientID: "kubernetes"
# Secret который я просил записать
ClientSecret: "d0b41895-c42d-4e2c-95da-08d88a2d50fa"
# Куда перенаправить в случае успешной авторизации. Формат <SCHEMA>://<SERVICE_NAME>.><NAMESAPCE>.<CLUSTER_NAME>
#upstreamURL: "http://kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local"
upstreamURL: "https://dash-k8s.company.ru"
#"http://kubernetes-dashboard.kubernetes-dashboard.svc.cluster.local"
# Пропускаем проверку сертификата, если у нас самоподписанный
skipOpenidProviderTlsVerify: true
# Настройка прав доступа, пускаем на все path если мы в группе kubernetes-dashboard and kubernetes-reader
rules:
  - "uri=/*|groups=kubernetes-admin,kubernetes-reader"

```
```
helm repo add gabibbo97 https://gabibbo97.github.io/charts/
helm upgrade --install -f gate.yml -n kubernetes-dashboard keycloak-gatekeeper gabibbo97/keycloak-gatekeeper
```
