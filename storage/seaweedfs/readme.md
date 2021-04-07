
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
Поднимаем 5 тачек Centos8, добавляем диск /data/, где будут распологаться volume. Указываем необходимые роли.
seaweed1 ansible_host='10.3.3.1' weed_master=true weed_filer=true weed_volume=true
seaweed2 ansible_host='10.3.3.2' weed_master=true weed_filer=true weed_volume=true
seaweed3 ansible_host='10.3.3.3' weed_master=true weed_volume=true
seaweed3 ansible_host='10.3.3.4' weed_master=true weed_volume=true
seaweed4 ansible_host='10.3.3.5' weed_db=true
seaweed5 ansible_host='10.3.3.6' weed_db=true

Устанавливаем postgres cluster на 10.3.3.4 & 10.3.3.5 (делал через clustercontrol). Добавляем юзера в postgres и вбиваем эти данные в filer.toml
Проверяем настройки в defaults/main.yml

Добавляем юзеров в s3.json.j2 в templates

# CHECK WORKING
в системе будет шаблон в /etc/systemd/system/swfs@.service
Master
Первым делом запускаются master-сервисы
Конфиг для мастеров тут - /etc/seaweedfs/master.conf
OPTS="-peers 10.3.3.1:9333,10.3.3.2:9333,10.3.3.3:9333 -ip 10.3.3.1:9333 -port 9333 -mdir /data/seaweedfs/data"
В параметре -peers перечислены все master-серверы
В параметре -ip указан IP текущего сервера
В параметре -mdir указана рабочая директория. Тут будут логи и т.д.
Активируем и запускаем master-серверы:
systemctl enable --now seaweedfs@master
Можно заходить на каждый master-сервер по порту 9333 (например http://10.3.3.1:9333 )

Volume
Вольюмы будут расположены на всех перечисленных в данном примере серверах. Их содержимое будет располагаться в /data/seaweedfs/data/volume
Вольюмы могут располагаться в разных датацентрах и рэках (стойках). Между датацентрами и рэками можно настраивать репликацию.

Воспользуемся этой возможностью. Предположим, что все вольюмы находятся в одном датацентре, но:

10.3.3.1 и 10.3.3.2 - расположены в рэке под именем rack1
10.3.3.3 и 10.3.3.4 - расположены в рэке под именем rack2
Создаём на каждом сервере конфиг /etc/seaweedfs/volume.conf:

touch /etc/seaweedfs/volume.conf && chown seaweedfs:seaweedfs /etc/seaweedfs/volume.conf
На серверах 10.3.3.1 и 10.3.3.2 он выглядит следующим образом:

OPTS="-mserver 10.3.3.1:9333,10.3.3.2:9333,10.3.3.3:9333 -dir /data/seaweedfs/data -ip 10.3.3.1 -dataCenter stage -rack rack1"
где
-mserver - все master-серверы
-dir - каталог для хранения файлов
-ip - адрес текущей ВМ
-dataCenter - имя датацентра
-rack - имя рэка
По аналогии конфиг добавляется на серверах 10.3.3.3 и 10.3.3.4:

OPTS="-mserver 10.3.3.1:9333,10.3.3.2:9333,10.3.3.3:9333 -dir /data/seaweedfs/data -ip 10.3.3.3 -dataCenter stage -rack rack2"
Параметр -rack здесь уже имеет значение rack2
Запускаем:
systemctl enable --now seaweedfs@volume

Filer
Изначально мы определились, что будем хранить метаданные в pgsql.
необходимо в БД и создать там таблицу:
CREATE TABLE IF NOT EXISTS filemeta (
  dirhash     BIGINT,
  name        VARCHAR(65535),
  directory   VARCHAR(65535),
  meta        bytea,
  PRIMARY KEY (dirhash, name)
);
В этом примере файлеры будут расположены на серверах 10.3.3.1 и 10.3.3.2.
Так что создаём на них конфиг /etc/seaweedfs/filer.conf:
touch /etc/seaweedfs/filer.conf && chown seaweedfs:seaweedfs /etc/seaweedfs/filer.conf
со следующим содержимым
-master 10.3.3.1:9333,10.3.3.2:9333,10.3.3.3:9333 -ip 10.3.3.1:9333 -dataCenter stage -defaultReplicaPlacement 010
где:
-master - все master-серверы
-ip - IP текущего сервера
-dataCenter - название датацентра, которому принадлежит данных файлер
-defaultReplicaPlacement - политика репликации
Параметру defaultReplicaPlacement следует уделить особое внимание.

Параметр имеет структуру XYZ
X - число реплик в разных датацентрах
Y - число реплик в разных рэках одного датацентра
Z - число реплик на разных серверах одного рэка
Нам нужна одна реплика в каждом рэке, поэтому используем 010

Теперь нужен ещё один конфиг для подключения к БД - /etc/seaweedfs/filer.toml (не путать с /etc/seaweedfs/filer.conf)
touch /etc/seaweedfs/filer.toml && chown seaweedfs:seaweedfs /etc/seaweedfs/filer.toml
со следующим содержимым
[postgres]
enabled = true
hostname = "10.3.3.5:9333"
port = 5432
username = "seaweedfs"
password = "seaweedfs"
database = "seaweedfs"
sslmode = "disable"
connection_max_idle = 100
connection_max_open = 100
И, запускаем
systemctl enable --now seaweedfs@filer
Теперь можно открывать в браузере http://10.3.3.1:8888 или http://10.3.3.2:8888 и загружать файлы. 

# s3
S3
Один запущенный процесс weed s3 связан с одним файлером.
Предположим, что S3 API будет доступно на серверах 10.3.3.1 и 10.3.3.2.
Сразу же стоит учесть, что у каждого узла свой конфиг для доступа к S3, поэтому нужно следить, чтобы они были везде одинаковыми.
Итак, создаём 2 файла
touch /etc/seaweedfs/s3.conf && chown seaweedfs:seaweedfs /etc/seaweedfs/s3.conf
touch /etc/seaweedfs/s3.json && chown seaweedfs:seaweedfs /etc/seaweedfs/s3.json
Содержимое s3.conf
OPTS="-port=8333 -filer 10.3.3.1:8888 -config /etc/seaweedfs/s3.json"
10.3.3.1:8888 - это адрес файлера, с которым будет связан текущий S3.
s3cmd
# проверить подключение
echo -e "defaultuser\n23213123123123wqerwr235235\n\n10.3.3.1:8333\n10.3.3.1:8333\n\n/bin/gpg\nfalse\n\n\ny" |   s3cmd --configure
```
