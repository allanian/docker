# Create first app
helm create test
cd test

charts/:  управляемые вручную зависимости пакета, хотя обычно лучше использовать файл requirements.yaml для динамической привязки зависимостей.
templates/: файлы шаблона, которые комбинируются со значениями конфигурации (из файла values.yaml и командной строки) и записываются в манифесты Kubernetes.
Chart.yaml: файл с метаданными о пакете (название/версия пакета, информацию об обслуживании, актуальный сайт и ключевые слова для поиска.
LICENSE: лицензия пакета в текстовом формате.
README.md: файл readme.
requirements.yaml: зависимости пакета.
values.yaml: конфигурация пакета по умолчанию.

helm create dsatest
rm -rf dsatest/templates/*
rm -rf dsatest/values.yaml

# check
helm install test  --dry-run --name test123 --debug dsatest/ 
helm install --debug --dry-run --name test123 dsatest/  --namespace dsatest --create-namespace
# install
helm install dsatest dsatest/
# status
helm get manifest dsatest
kubectl describe cm nginx-configmap
# delete
helm uninstall dsatest
# upgrade
helm upgrade dsatest dsatest/ --set user=AnotherOneUser
# package
helm  package dsatest/

