```
Создаем архив в проекте
    environment {
        ARTIFACT_NAME_ZHS_BACK = 'zhs_back_test.tar.gz'
    }
	archiveArtifacts "${ARTIFACT_NAME_ZHS_BACK}"
Так же можно расшаривать проект между STAGE – через stash/unstash
pipeline {
    agent none
    environment {
        ARTIFACT_NAME_ZHS_BACK = 'zhs_back_test.tar.gz'
    }
    stages {
        stage('build project in container') {
			agent {
				docker {
					label 'Jenkins-slave-CI-PRO'
					image 'registry.docker.company.org:5001/zhs/zhs-backend/composer_php72_npm:latest'
					registryCredentialsId 'token'
					registryUrl 'https://registry.docker.company.org:5001/'
					args '-u root:root'
				}
			}
			steps {
				checkout([$class: 'GitSCM', branches: [[name: '*/test']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'bc02ab1b-6631-4250-91f7-03d520b374a1', url: 'http://git2.company.org/zhs/zhs-backend.git']]])
					sh """	
						chmod +x ./pre_deploy.sh
						./pre_deploy.sh
						rm -rf ${ARTIFACT_NAME_ZHS_BACK}
						cd ..
						# for tar without full path	tar -zcf ./1.tar.gz -C /app/test .
						tar -czf ${ARTIFACT_NAME_ZHS_BACK} -C '${WORKSPACE}' .
						mv ${ARTIFACT_NAME_ZHS_BACK} ${WORKSPACE}
					"""	
					//	stash name: "testback", includes: "**", useDefaultExcludes: false
                    stash name: "testback", includes: "${ARTIFACT_NAME_ZHS_BACK}", useDefaultExcludes: false

					//	archiveArtifacts "${ARTIFACT_NAME_ZHS_BACK}"
					}
        }
        stage('deploy project') {
			agent {
				label 'ZHS-NLB5P_slave'
			}
			steps {
				dir('/tmp/zhs_back_test'){
					unstash 'testback'
					sh 'ls -la'
					sh """
						ls -la
						ssh -o StrictHostKeyChecking=no jenkins@172.24.43.200 'rm -rf /data/zhs/backend && mkdir -p /data/zhs/backend'
						scp -r ${ARTIFACT_NAME_ZHS_BACK} jenkins@172.24.43.200:/data/zhs/backend/
						ssh -o StrictHostKeyChecking=no jenkins@172.24.43.200 'cd /data/zhs/backend && tar -xf ${ARTIFACT_NAME_ZHS_BACK}'
						ssh -o StrictHostKeyChecking=no jenkins@172.24.43.200 'chmod +x /data/zhs/deploy_backend.sh'
					"""
				}
				
				script {
					status = sh(
						returnStatus: true,
						script: "ssh -o StrictHostKeyChecking=no jenkins@172.24.43.200 '/data/zhs/deploy_backend.sh'"
					)
				//	sh "echo \"exit code is : ${status}\""
					
					if (status != 0) 
					{ 
						error 'exit code in NOT zero - ${status}'
					} 
					else 
					{
						sh "echo 'exit code is zero -  ${status}'"
					}
				}
			}
        }
    }
}

```
