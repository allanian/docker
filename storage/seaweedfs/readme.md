
```
#есть написанная роль в ansible
как это работает
Сущности:
В идеале это 12 серверов (3 мастера, 3 filer, 3 database, 3 volume)
1) MASTER
3 мастер ноды
главный мастер выбирается через протокол RAFT (кто первый, тот и главный)
2) FILER
filer - два  systemd сервиса на мастер серверах
Database - два отдельных сервера в кластере (postgres), используется для хранения метаданных с filer, для надежности, метаданные содержат путь к данным.
S3 - два S3 сервиса на серверах где расположен filer.
3) VOLUME
3 отдельных сервера или больше для хранения данных, можно расположить и на мастер серверах.

# Установка
Поднимаем 5 тачек добавляем диск, где будут распологаться volume
seaweed1 ansible_host='10.3.3.1' weed_master=true weed_filer=true weed_volume=true
seaweed2 ansible_host='10.3.3.2' weed_master=true weed_filer=true weed_volume=true
seaweed3 ansible_host='10.3.3.3' weed_master=true weed_volume=true
seaweed4 ansible_host='10.3.3.4' weed_db=true
seaweed5 ansible_host='10.3.3.5' weed_db=true

Устанавливаем postgres cluster на 10.3.3.4 & 10.3.3.5 (делал через clustercontrol). Добавляем юзера в postgres и вбиваем эти данные в filer.toml
Проверяем настройки в defaults/main.yml

Добавляем юзеров в s3.json.j2 в templates


# s3
s3cmd
# проверить подключение
echo -e "defaultuser\n23213123123123wqerwr235235\n\n10.3.3.1:8333\n10.3.3.1:8333\n\n/bin/gpg\nfalse\n\n\ny" |   s3cmd --configure
```
