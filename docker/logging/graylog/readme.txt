Поднимаем DOCKER-COMPOSE
Закидываем конфиги
mkdir -p ./graylog/config
cd ./graylog/config
wget https://raw.githubusercontent.com/Graylog2/graylog-docker/2.4/config/graylog.conf
wget https://raw.githubusercontent.com/Graylog2/graylog-docker/2.4/config/log4j2.xml


1 config
Поднимаем DOCKER-COMPOSE
Закидываем конфиги
mkdir -p ./graylog/config
cd ./graylog/config
wget https://raw.githubusercontent.com/Graylog2/graylog-docker/2.4/config/graylog.conf
wget https://raw.githubusercontent.com/Graylog2/graylog-docker/2.4/config/log4j2.xml


Создаем Input для приема логов.
Menu->System/Inputs
Syslog UDP->Launch new Input
Title - Collect Logs from RemoteServer
Node – выбираем какая есть
IP – ставим 0.0.0.0
Port 1234 (больше 1024)


WEB GRAYLOG
Создаем intput
System/Inputs
Syslog UDP->Launch new Input
Collect Logs from RemoteServer
Node – выбрать нужный
IP 0.0.0.0
Port 1234

Проверка работы
echo "Hello Graylog" | nc -w 1 -u 172.29.27.7 1234
echo "Hello Graylog" | nc -w 1 -u 172.29.74.4 1234

http://172.29.74.4



Настройка отправки логов RSYSLOG
https://rtfm.co.ua/rsyslog-dobavlenie-nablyudeniya-za-fajlom-v-konfiguraciyu/
http://www.k-max.name/linux/rsyslog-na-debian-nastrojka-servera/
sudo yum install rsyslog
sudo systemctl status rsyslog.service

sudo yum install nano
sudo nano /etc/rsyslog.conf
В самом низу добавить ip и порт для input
*.* @172.29.27.7:1234

sudo systemctl restart rsyslog.service
sudo systemctl status rsyslog.service

#check rsyslog listening port 1234
sudo netstat -antup | grep 1234
RSYSLOG отправка нужного лога
Создаем конфиг в папке
sudo nano /etc/rsyslog.d/parklog.conf

# /etc/rsyslog.d/parklog.conf

$ModLoad imfile

$InputFileName /var/log/testlog.log
$InputFileTag testlog:
$InputFileStateFile testlog1
$InputFileFacility local3

$InputFileSeverity warning
$InputRunFileMonitor
$InputFilePollInterval 1

*.* @172.29.27.7

Перезапускаем rsyslog
Добавляем запись в /var/log/testlog.log
И она появится в GRAYLOG
GRAYLOG – ACTIVE DIRECTORY
•	Включить поддержку LDAP в разделе настроек System/Authentication - Authenticarion - LDAP/Active Directory
•	Создать учетную запись для подключения к Active Directory
•	Создать несколько простейших LDAP фильтров (про специфику LDAP запросов, можно прочитать например ЗДЕСЬ)
•	Указать LDAP фильтры в настройках LDAP подключения
