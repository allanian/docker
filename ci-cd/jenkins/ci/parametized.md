
```
Параметезированная сборка с maven
настраиваем ноду с мавен

CI/CD 
PRE_STEP - exec shell
export BUILD_NUMBER=0
export MAVEN_HOME=/usr/share/apache-maven
chmod 777 /data/workspace/OpenCityRegions/OpenCitySaas/ag_russia_cms/./driver/chromedriver_linux
chmod 777 /data/workspace/OpenCityRegions/OpenCitySaas/ag_russia_cms/./driver/chromedriver_linux --version
 
echo $build

Параметры
Build
Maven Version maven
Root POM pom.xml
Goals and options ${build}

This project is parameterized
Name build

clean test -P dev_tests-chelyabinsk site
clean test -P dev_tests-box site
clean test -P test-saas site
```
