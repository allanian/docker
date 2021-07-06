```
ZABBIX SSO
# on zabbix server
cd /usr/share/zabbix/conf/certs
openssl req -x509 -sha256 -newkey rsa:2048 -keyout sp.key -out sp.crt -days 3650 -nodes -subj '/CN=zabbix.company.ru'

# open keycloak url with cert
https://keycloak.company.ru/auth/realms/rendez-vous/protocol/saml/descriptor
cd /usr/share/zabbix/conf/certs
nano idp.crt
-----BEGIN CERTIFICATE-----
MIICpTCCAY0CBgF5raKLtjANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAtyZW5kZXotdm91czAeFw0yMTA1MjcxMTQxMjFaFw0zMTA1MjcxMTQzMDFaM
BYxFDASBgNVBAMMC3JlbmRlei12b3VzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi4bq+J8OoCxfI2quAfo3NW7y2xYuPYFGDjJPcf7phl
2zdOODxA/hnXr9IzluUj5yMK5tGG8mk1rWj4CTtyOxgzZehy3c8VuIATW3QyIpE2TAO5AdJ2YJ5fNu7Kjp0CgeHjrmUOgC8LDkJoNrcPmWY+IYNUetPq
7609SIOoQ7ci6FN5NkrgE6kpwG964XWHvbzrPbEdBqX6eVBlutJtyeM9craEfyCu4blZ/1PS+/LAuDIPMWl8r71LI3OTdO3sMPAoemBuHRe0f7kMRzLh
ZC5Yom59KUOGmvwEmiNtz1ZAiYYghDdlPEbWWCks/mJqSVFQJOngABVSPD6C7HvQY1zwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAI/MD2svMISvhBue/
8luuJrxeb62WuE+b1ZG8U/dt8MO676/eLUpzKb69yoXXlsoTky5JgenmnTt6N0KA3sSQvMnkQIusmIJKvAz4k/5btC8fvTMaqiltYazKR4c9piqkrAy7l
f0Ke0HRc3jLRA+6o9YrWp3CswCVUwSPxsBpS5jlWCJBkzWMr4s5ZVqxr7odlntd1IkD2FD3Y/Ib62ktD8FJd5lC6UO86RbfO6stKrZhNsMxMkewyuk7uP
DDwp2ZqY3TkEWa6l1BnuyeGL511fv+D1A6e6X9NpqchaYXVTRhpM4+pNuQA+JPQdewTLlILBbMXORWQwn/NA2Du8Tyc
-----END CERTIFICATE-----

chmod 644 idp.crt
chmod +x idp.crt

# go to keycloak web admin
add new client
CLIENT ID - zabbix
Clint protocol - saml
Name ID Format - email\\



SET GLOBAL log_timestamps = 'SYSTEM';
LANG=EN_us mount /dev/sdb1 /mnt -t xfs -o rw,noatime

CREATE USER 'keycloak'@'%' IDENTIFIED BY 'QWE123qwe';
GRANT ALL PRIVILEGES ON *.* TO 'keycloak'@'%';
```
