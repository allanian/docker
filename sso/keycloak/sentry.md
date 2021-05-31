# Note!
```
Need Platinum License
```
# SENTRY

# Create a client
Click "Clients" > "Create".
For the required "Client ID" field, just type something like https://sentry.example.com/saml/metadata/example/, assuming the sentry server is at sentry.example.com, and the organization slug in sentry is example.  http://10.3.3.182:9000/organizations/sentry/projects/
| Option | Value |
| ------ | ------ |
| Client ID | https://sentry.company.ru/metadata/company |
| Client Protocol | saml |
Click "Save".

Configure the client
| Option | Value |
| ------ | ------ |
| Client Protocol | saml |
| Sign Assertions | OFF |
| Encrypt Assertions | OFF |
| Client Signature Required | OFF |
| Force POST Binding | OFF |
| Force Name ID Format | OFF |
| Name ID Format | email |
| Valid Redirect URIs | * |
| Assertion Consumer Service POST Binding URL | https://sentry.company.ru/saml/acs/company/ |
| Logout Service POST Binding URL | https://sentry.company.ru/saml/sls/company/ |
Leave the rest as they are.


Configure Mappers
Click "Delete" on the default "role list", and confirm, as we will use a builtin mapper.
Click "Add Builtin", check "X500 email", and click "Add selected".
Click "X500 Email", and change "SAML Attribute Name" to user_email, as that's what Sentry expects. Click Save.

We are done with Keycloak setup, now let's setup Sentry side.



go to realm settings
copy Endpoints for SAML2
http://10.3.3.226:8080/auth/realms/company/protocol/saml/descriptor
http://10.3.3.226:8080/auth/realms/company/broker/saml/endpoint/descriptor
# go to sentry
add auth => saml2
For Attribute Mappings, use user_email for both "IdP User ID" and "User Email" required fields.

http://10.3.3.226:8080/auth/realms/company/protocol/saml/descriptor

