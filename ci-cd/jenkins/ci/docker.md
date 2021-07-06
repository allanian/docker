# Docker build image
```
Docker build
		stage('docker build image and copy data') {
			agent {
				label 'Jenkins-slave-CI-PRO'
			}
			steps{
				script {
				    sh "ls -la /data/build2/workspace/ZHS/zhs_back_deploy_test_pipeline"
					docker.withRegistry('https://registry.docker.altarix.org:5001/','bc02ab1b-6631-4250-91f7-03d520b374a1') {
						image = docker.build 'registry.docker.altarix.org:5001/zhs/zhs-backend/composer_php72_npm_data', "-f Dockerfile ."
						image.push()
                   //   docker.image('registry.docker.altarix.org:5001/zhs/zhs-backend/composer_php72_npm').inside {
                 //     sh 'echo test'
                //      }
					}
				}
			}
		}

```
