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
					docker.withRegistry('https://registry.docker.company.org:5001/','token') {
						image = docker.build 'registry.docker.company.org:5001/zhs/zhs-backend/composer_php72_npm_data', "-f Dockerfile ."
						image.push()
                   //   docker.image('registry.docker.company.org:5001/zhs/zhs-backend/composer_php72_npm').inside {
                 //     sh 'echo test'
                //      }
					}
				}
			}
		}

```
