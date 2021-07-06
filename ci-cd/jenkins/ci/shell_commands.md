```
pipeline {
    agent none
    stages {
        stage('test') {
			agent {
					label 'Jenkins-slave-CI-PRO'
			}
			steps {
				checkout([$class: 'GitSCM', branches: [[name: '*/test']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'token', url: 'http://git2.altarix.org/user/testzhs.git']]])
					sh """	
						echo 'test'
						echo 'test'
						echo 'test'
					"""	
					}
        }
    }
}

```
