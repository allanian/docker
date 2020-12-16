docker run  \
--entrypoint /bin/bash    \
-v $(pwd):/var/loadtest   \
-v $HOME/.ssh:/root/.ssh  \
-it direvius/yandex-tank

yandex-tank -c load.yaml

PHANTOM:
phantom:
  address: 192.168.1.164:8080
  ssl: false
  load_profile:
    load_type: rps
    schedule: const(10, 1m)
  ammofile: ammo.txt
  ammo_type: uripost

phantom:
  address: 192.168.1.164:80
  ssl: false
  uris: 
  - /api/external/v1.0/ExternalAction/GetDeviceList?work_place_external_id=workplace_test
  load_profile:
    load_type: rps
    schedule: line(1000, 10000, 10s)
#  ammofile: ammo.txt
  instances: 20000


nano monitoring.xml


	SERVER WITH SERVICE
•	SERVER WITH YANDEX TANK
PLAN:
1) on server with yandex tank create config load.yaml
PHANTOM:
phantom:
  address: 192.168.1.164:8080
  ssl: false
  load_profile:
    load_type: rps
    schedule: const(10, 1m)
  ammofile: ammo.txt
  ammo_type: uripost

phantom:
  address: 192.168.1.164:80
  ssl: false
  uris: 
  - /api/external/v1.0/ExternalAction/GetDeviceList?work_place_external_id=workplace_test
  load_profile:
    load_type: rps
    schedule: line(1000, 10000, 10s)
#  ammofile: ammo.txt
  instances: 20000
address – домен (или ip-адрес) и порт цели.
SSL - Если нужна поддержка https.
load_profile – поведение профиля нагрузки. Тут задаётся нагрузка и продолжительность стрельб. Укажите тип load_type (rps, запланируйте нагрузку, определяя запросы в секунду или экземпляры - запланируйте нагрузку, определяя параллельные активные потоки) и расписание.
    schedule: line(1000, 205000, 5m)
значит начни с 1000 запросов в секунду иди до 205000 в течении 5минут
ammofile – файл с патронами (запросами к цели). Есть несколько способов задавать патроны.
instances - Max number of instances (concurrent requests).
Loop - Number of times requests from ammo file are repeated in loop.
ammo_limit - Limit request number.
autostop:
  autostop:
    - time(50, 30s)
    - net(110, 5%, 10s)
autostop=time(50,15) означает "остановиться, если среднее время ответа для каждой секунды в интервале 15 с превышает 50 мс".
TELEGRAF:
For use him copy ssh_key from server with yandex tank to server with service
Runs metrics collection through SSH connection. 
telegraf:
  enabled: true
  config: monitoring.xml
  kill_old: false
  package: yandextank.plugins.Telegraf
  ssh_timeout: 30s

config – Путь к конфигурационному файлу
ssh_timeout - Ssh connection timeout.

nano monitoring.xml
<Monitoring>
  <Host address="192.168.1.164" interval="1" username="root">
    <CPU/> <Kernel/> <Net/> <System/> <Memory/> <Disk/> <Netstat /> <Nstat/>
  </Host>
</Monitoring>

UPLOADER (Overload):
overload:
  token_file: token.txt
  job_name: test
  job_dsc: test description
token_file - Для этого нужно авторизоваться на сайте https://overload.yandex.net/ , кликнуть на аватарку и скопировать токен. Затем нужно создать файл token.txt и положить туда токен.
nano token.txt
6e681d85bdac428ab3a827b77de97384
job_name - (Optional) Name of a job to be displayed in Yandex.Overload
job_dsc - (Optional) Description of a job to be displayed in Yandex.Overload
Создание AMMO
https://yandextank.readthedocs.io/en/latest/ammo_generators.html
copy into file make_ammo.py and change HOSTNAME
chmod +x make_ammo.py
echo "GET||/url||case||" | ./make_ammo.py > ammo.txt
/url — какой URI опрашивать, 
case — тег удобно использовать для статистики. То есть можно тегировать патроны с разными задачами, а потом в консоле и интерфейсе https://overload.yandex.net/ наблюдать статистику по каждому тегу. Скорее всего это будет полезной фичей при тестировании API. Теги опциональны:
$ echo "POST||/url||||" | ./make_ammo.py > ammo.txt
В скрипт я добавил поддержку keep-alive и application/json (использовал для POST-запросов с payload) заменив на 51 сточке Connection: close\r\n на след.:
"Content-Type: application/json\r\n" + \
"Connection: keep-alive"
Content-Type не нужен если вы используете GET-запросы с keep-alive. Если нужно набить максильное значение RPS, просто измените Connection. POST/GET-запрос не имеет значение.
Конечно вы вольны добавлять любые заголовки, особенно это будет полезно при тестировании API.
FULL CONFIG
Запуск
mkdir -p /home/gilmullinrr/tank/
здесь создаем файл конфига load.yml
docker run 
  --entrypoint /bin/bash    // подключаемся к контейнеру (иначе контейнер будет остановлен после окончания стрельб)
  -v $(pwd):/var/loadtest   // монтируем текущую директорию (в ней будут конфиги и патроны)
  -v $HOME/.ssh:/root/.ssh  // монтируем папку с ssh-ключами (для настройки мониторинга)
  -it direvius/yandex-tank  // публичный образ Яндекс.Танка

docker run \
    -v $(pwd):/var/loadtest \
    -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent \
    --net host \
    -it direvius/yandex-tank

Запустил так
docker run  \
  --entrypoint /bin/bash    \
-v $(pwd):/var/loadtest   \
  -v $HOME/.ssh:/root/.ssh  \
  -it direvius/yandex-tank
Внутри выполнил
yandex-tank -c load.yml



Модуль: telegraf
Очень классная штука: позволяет мониторить удаленный сервер и позволяет не только показывать данные в консоле во время тестирования, но и отправлять на https://overload.yandex.net. Это очень удобно для последующего анализа запросов.
Работает через SSH. Обычным образом устанавливаем ключи у себя и на удаленной машине. Конфиг, monitoring.xml:
Следует заменить HOST и USER на свои значения.
<Monitoring>
  <Host address="74.207.235.19" interval="1" username="root">
    <CPU/> <Kernel/> <Net/> <System/> <Memory/> <Disk/> <Netstat /> <Nstat/>
  </Host>
</Monitoring>


Модуль: overload
Модуль для отправки метрик на https://overload.yandex.net для последующего анализа. Создайте файл token.txt и положите туда токен, который можно получить на этом же сайте после регистрации.
По желаюнию можно использовать параметры job_name / job_dsc чтоб потом не заполнять описание ручками на сайте.

Патроны
Это то, что полетит в цель, как бы банально это не звучало. То есть возможность подготивить серию патронов и обстреливать цель, а не дергать за один тест только один URL. Для довольно сложных сценариев правильней использовать JMeter. Я же использовал Phantom.
Есть два варианта где держать патроны: в конфиге yandex-tank или в отдельном файле. Мне кажется в отдельном файле куда удобнее. Можно использовать скрипт для генерации патронов.



docker run    --entrypoint /bin/bash    -v $(pwd):/var/loadtest     -v $HOME/.ssh:/root/.ssh    -it direvius/yandex-tank


rockmagicnet/yandex-tank-jmeter:latest
docker run              rockmagic/yandex-tank-jmeter

docker run  \
  --entrypoint /bin/bash    \
  -v $HOME/.ssh:/root/.ssh  \
  -v $(pwd):/var/loadtest   \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  --net host \
  -it rockmagicnet/yandex-tank-jmeter:latest

on target host install it
sudo apt install python2




docker run  \
  --entrypoint /bin/bash    \
-v $(pwd):/var/loadtest   \
  -v $HOME/.ssh:/root/.ssh  \
  -it direvius/yandex-tank
