# APACHE
nano rbac.yml
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard-view
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-dashboard-view-role
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
  name: ubernetes-dashboard-view-rolebind
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard-view-role
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
  ```  
  

## HTTPD CONFIG
```
yum -y install httpd mod_ldap
nano /etc/httpd/httpd.conf
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>


nano /etc/httpd/conf.d/ldap.conf
### change token
kubectl -n kubernetes-dashboard describe secret kubernetes-dashboard-view-token-jhljw
```

```
<VirtualHost *:80>
        RewriteEngine On
        RewriteCond %{HTTPS} !=on
        RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R=301,L]
</virtualhost>
<VirtualHost *:443>
        ServerAdmin k8s-ldap@localhost
        DocumentRoot /var/www/html
        ErrorLog /var/log/httpd/error_log
        CustomLog /var/log/httpd/access_log combined
        SSLEngine on
        SSLCertificateFile /etc/httpd/certificate/apache-certificate.crt
        SSLCertificateKeyFile /etc/httpd/certificate/apache.key
        SSLProxyEngine On
        SSLProxyVerify none
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        SSLProxyCACertificateFile /etc/kubernetes/pki/ca.crt
        # cat /etc/kubernetes/pki/front-proxy-client.crt /etc/kubernetes/pki/front-proxy-client.key > /etc/httpd/certificate/front-proxy-client.pem
        SSLProxyMachineCertificateFile /etc/httpd/certificate/front-proxy-client.pem
        # token from command - kubectl describe -n kube-system secret apache-proxy-token-8gk9p
        RequestHeader set Authorization "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjNHWTU2Y28xSmZqOXN5cDlxQnZuVGJ3dUQ2YkFYWmNtMVVUQzBZWXQxSVUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL"
<Location />
	AuthType Basic
        AuthName "Secure area - Authentication required"
        AuthBasicAuthoritative Off
        #yum -y install mod_ldap
        AuthBasicProvider ldap
        # LDAP CONFIG
        SSLRequireSSL
        AuthLDAPURL "ldap://company.ru/DC=company,DC=ru?sAMAccountName?sub?(objectClass=*)"
        AuthLDAPBindDN "CN=user,DC=company,DC=ru"
        AuthLDAPBindPassword "password"
        #Require valid-user
        # group
#        AuthLDAPGroupAttribute member
#        AuthLDAPSubGroupClass group
#        AuthLDAPGroupAttributeIsDN On
#        AuthLDAPMaxSubGroupDepth 0
        #Require valid-user
  <RequireAny>
    Require ldap-group CN=k8s_read_only,OU=group_it,DC=company,DC=ru
  </RequireAny>

        # kubectl get Service -n kubernetes-dashboard
        # dashboard url - ip
        ProxyPass  https://172.11.11.11:30000/
        # dashboard url
        ProxyPassReverse  https://k8s.company.ru/
</Location>
</VirtualHost>
```
