```
EMAIL
def sendEmails() {
    emailext body: "See ${env.BUILD_URL}",
            recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
            subject: "Jenkins Build Successful",
            to: "user@company.ru"
}

```
