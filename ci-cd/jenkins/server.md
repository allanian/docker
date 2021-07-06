# SERVER
## ADD SERVER, where you want to run your jobs
```
https://jenkins.company.ru/configure
Проматываем вниз
Жмем Добавить
SSH server:
Name - server1
Hostname - server1_ip
Username - jenkins
Remote Directory - /
Жмем расширенные и добавляем ключ и пароль;
Жмем TEST CONFIGURATION
Не забываем добавить публичный ключ и создать эту учетку на сервере
nano /etc/ssh/authorized_keys/jenkins
Жмем сохранить

```
