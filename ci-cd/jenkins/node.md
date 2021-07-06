# NODE
## ADD NODE
```
http://www.itkitchen.net/add-slave-node-in-jenkins/

# ADD AGENT NODE FOR APP
Не работает если настроено через ssh
https://linuxacademy.com/blog/devops/adding-a-jenkins-agent-node/

## ON WEB
Add new slave agent – node
https://jenkins.company.ru/computer/new
Permanent Agent - true
Name - name of agent
Labels - gradle-node (example)
Root of filesystem - /data/jenkins_data
Using - Only build jobs with label expressions matching this node
Run - Launch agent via Java Web Start
Accessible - Keep this agent online as much as possible
LAUNCH COMMAND BY MASTER !!!! in new releases
Потом он выдаст ссылки где скачать все

## ON SERVER
yum install java-1.8.0-openjdk.x86_64
mkdir -p /data/jenkins/slave
cd /data/jenkins/slave

curl -u user:password https://jenkins.company.ru/computer/ZHS-NLB5P_slave/slave-agent.jnlp -o /data/jenkins/slave/slave-agent.jnlp
curl -u user:password https://jenkins.company.ru/jnlpJars/agent.jar -o /data/jenkins/slave/agent.jar
chown -R jenkins:jenkins /data/jenkins/slave
nano /etc/systemd/system/jenkins_slave.service
 [Unit]
Description=jenkins_slave
[Service]
PIDFile=/data/jenkins/slave/slave.pid
User=jenkins
ExecStart=/bin/java -jar /data/jenkins/slave/agent.jar -jnlpUrl https://jenkins.altarix.ru/computer/ZHS-NLB5P_slave/slave-agent.jnlp -secret 63d0f7ad4ec43c4de2d04c61e4c75a20cc374c6b4b021ef778b1950e46f76cab -workDir /data/jenkins/slave
[Install]
WantedBy=multi-user.target
[Install]
WantedBy=multi-user.target

# не забываем править имя slave
USERNAME - ваш логин для jenkins
PASSWORD - ваш пароль для jenkins
SLAVE_NAME - имя нового слейва
SECRET - секрет (скопировать из Uки мастера. В строке "Run from agent command line" -secret blabla)

usermod –aG docker jenkins
systemctl daemon-reload
systemctl enable jenkins_slave.service
systemctl start jenkins_slave.service
systemctl status jenkins_slave.service
https://jenkins.company.ru/computer/new
тут можно глянуть статус
https://jenkins.company.ru/computer/ZHS-NLB5P_slave/

```
