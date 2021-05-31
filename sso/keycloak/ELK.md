# Note!
```
Need license Platinum!
```


# config elasticsearch.yml
```
# api keys
xpack.security.authc.api_key.enabled: true
xpack.security.authc.token.enabled: true

xpack.security.authc.realms.saml.rendez-vous:
  order: 2
  # file or path to keycloak
  #idp.metadata.path: "https://keycloak.rendez-vous.ru/auth/realms/rendez-vous/protocol/saml/descriptor"
  idp.metadata.path: "/usr/share/elasticsearch/config/saml/idp-metadata.xml"
  #The valid URL of the KeyCloak Realm SAML SSO endpoint. This is where the user will be redirected to when the user accesses Kibana
  idp.entity_id: "https://keycloak.rendez-vous.ru/auth/realms/rendez-vous"
  # The URL to be specified in the SAML request, as the requester, the Service Provider. This is where we will be using the publicly resolvable Kibana URL that we used earlier when configuring the KeyCloak SAML Client.
  sp.entity_id:  "https://10.3.3.182:8093/"
  # The Assertion Consumer Service URL of Kibana, where the SAML response will be consumed, and where the IDP should redirect the user with a proper SAML response. This URL should be one of the redirect URLs provided earlier when$
  sp.acs: "https://10.3.3.182:8093/api/security/v1/saml"
  # The Kibana endpoint to call on IDP initiated logouts.
  sp.logout: "https://10.3.3.182:8093/logout"
  #attributes.principal: "email"
  #attributes.groups: "realm"
  attributes.principal: "nameid"
  attributes.groups: "groups"
```

# config kibana.yml
```
# SAML SSO
server.xsrf.whitelist: [/api/security/v1/saml]
xpack.security.authc.providers:
  basic.basic1:
    order: 0
    icon: "logoElasticsearch"
    hint: "ES Local"
  saml.saml1:
    order: 1
    realm: "rendez-vous"
    description: "Log in with SSO"
    #icon: "https://my-company.xyz/saml-logo.svg"
```
