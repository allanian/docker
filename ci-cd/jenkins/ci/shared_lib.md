# Shared libriry
```
Пример:
написал функцию к примеру типо  sh "echo "hello" и тебе во всех нужно  ну вот сохраняешь vars/hello.groovy в паплайне самая первая строчка подключение библиотеки hello, а 
в шагах уже дёргаешь функцию
# Подключение
https://jenkins.company.ru/configure
Global Pipeline Libraries
Library
Name: surf-lib
Default version: master
Source Code Management
Git
https://github.com/surf/jenkins-pipeline-lib.git
Branch Specifier version-4.0.0-SNAPSHOT
В jenkinsfile
Подключаем её (вначале)
@Library('surf-lib@version-4.0.0-SNAPSHOT')

ОШИБКИ
java.lang.NoSuchMethodError: No such DSL method 'githubNotify' found among steps
значит нет необходимого плагина, идем в планины и ставим 'githubNotify'

‘Jenkins’ doesn’t have label ‘ios’
https://jenkins.company.ru/configure
Lockable Resources Manager
Add new ios in all fields




```
