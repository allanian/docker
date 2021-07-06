```
Discord webhook
    post {
		always {
	    	discordSend description: "Сборка завершена \n Статус: ${currentBuild.currentResult}", footer: "Номер сборки: ${BUILD_DISPLAY_NAME}", link: env.BUILD_URL, successful: currentBuild.resultIsBetterOrEqualTo('SUCCESS'), title: JOB_NAME, webhookURL: 'https://discordapp.com/api/webhooks/channel/token'
		}
	}

```
