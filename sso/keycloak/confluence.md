# CONFLUENCE SSO with keycloak
## Keycloak common data

go to keycloak => Realm Settings => EndPoints SAML 2.0 and copy next things:
https://keycloak.company.ru/auth/realms/company/protocol/saml/descriptor
```
ds:X509Certificate:
MIICpTCCAY0CBgF5raKLtjANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtyZW5kZXotdm91czAeFw0yMTA1MjcxMTQxMjFaFw0zMTA1MjcxMTQzMDFaMBYxFDASBgNVBAMMC3JlbmRlei12b3VzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi4bq+J8OoCxfI2quAfo3NW7y2xYuPYFGDjJPcf7phl2zdOODxA/hnXr9IzluUj5yMK5tGG8mk1rWj4CTtyOxgzZehy3c8VuIATW3QyIpE2TAO5AdJ2YJ5fNu7Kjp0CgeHjrmUOgC8LDkJoNrcPmWY+IYNUetPq7609SIOoQ7ci6FN5NkrgE6kpwG964XWHvbzrPbEdBqX6eVBlutJtyeM9craEfyCu4blZ/1PS+/LAuDIPMWl8r71LI3OTdO3sMPAoemBuHRe0f7kMRzLhZC5Yom59KUOGmvwEmiNtz1ZAiYYghDdlPEbWWCks/mJqSVFQJOngABVSPD6C7HvQY1zwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAI/MD2svMISvhBue/8luuJrxeb62WuE+b1ZG8U/dt8MO676/eLUpzKb69yoXXlsoTky5JgenmnTt6N0KA3sSQvMnkQIusmIJKvAz4k/5btC8fvTMaqiltYazKR4c9piqkrAy7lf0Ke0HRc3jLRA+6o9YrWp3CswCVUwSPxsBpS5jlWCJBkzWMr4s5ZVqxr7odlntd1IkD2FD3Y/Ib62ktD8FJd5lC6UO86RbfO6stKrZhNsMxMkewyuk7uPDDwp2ZqY3TkEWa6l1BnuyeGL511fv+D1A6e6X9NpqchaYXVTRhpM4+pNuQA+JPQdewTLlILBbMXORWQwn/NA2Du8Tyc
entityID:
https://keycloak.company.ru/auth/realms/company
SingleSignOnService:
https://keycloak.company.ru/auth/realms/company/protocol/saml
```

## Confluence configuration
go to that page https://confluence.company.ru/plugins/servlet/authentication-config
Confluence => Configuration => SSO 2.0 => Saml single sign-on
```

Authentication method - Saml single sign-on
Single sign-on issuer - https://keycloak.company.ru/auth/realms/company
Identity provider single sign-on URL. - https://keycloak.company.ru/auth/realms/company/protocol/saml
X.509 Certificate - paste cert
Username mapping - ${NameID}
```
copy info from urls for sentry
```
Give these URLs to your identity provider
https://confluence.company.ru/plugins/servlet/samlconsumer
Audience URL (Entity ID)
https://confluence.company.ru
```
Login mode:
Use SAML as secondary authentication

## Keycloak client
| Option | Value |
| ------ | ------ |
| Client ID | https://confluence.company.ru (value from Audience URL (Entity ID) confluence) |
| Enabled | ON |
| Client Protocol | saml |
| Include AuthnStatement | ON |
| Force Artifact Binding | OFF |
| Sign Assertions | ON |
| Signature Algorithm | RSA_SHA256 |
| SAML Signature Key Name | KEY_ID |
| Canonicalization Method | EXCLUSIVE |
| Encrypt Assertions | OFF |
| Client Signature Required | OFF |
| Force POST Binding | ON |
| Front Channel Logout | ON |
| Force Name ID Format | ON |
| Name ID Format | username |
| Valid Redirect URIs | https://confluence.company.ru/* |
| Master SAML Processing URL | https://confluence.company.ru/plugins/servlet/samlconsumer |

Leave the rest as they are.


### test
https://confluence.company.ru/plugins/servlet/external-login





