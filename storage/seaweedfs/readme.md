*The central master* не управляет всеми метаданными файлов на центральном мастере, а только управляет *file volumes*. Он управляет файлами и их метаданными через эти *volume servers*. Это снижает давление параллелизма со стороны *central master* и распределяет метаданные файлов на *volume server*, обеспечивая более быстрый доступ к файлам (O (1), обычно только одна операция чтения с диска). В метаданных каждого файла накладные расходы на дисковое хранилище составляют всего 40 байтов.
# SCHEMA
 ----------------------------------------------------------------------------------------------------------------
|             HttpClient
|                 |
|             MasterServer1 <====Http/Raft=====> MasterServer2 <====Http/Raft=====> MasterServer3(leader)
|                     ||                                    ||
|               ( grpc||HeartBeat)                   ( grpc||HeartBeat)
|                     ||                                    ||
 | ├─VolumeServer(Multiple) ├─VolumeServer(Multiple)
|                         ├─Stroage
|                             ├─VolumeData(.dat/.idx)
|                                ├─Needles
|                             ├─VolumeData(.dat/.idx)
|                                ├─Needles
|                         ├─Stroage
|                             ├─VolumeData(.dat/.idx)
|                                ├─Needles
|
----------------------------------------------------------------------------------------------------------------
*Data volume*: это физический носитель для хранения файлов, аналогичный физическим дискам. Значение по умолчанию - 32 ГБ, которое можно изменить до 64 или 128 ГБ. 
*Максимальный размер каждого файла не превышает размера одного тома.*
####PS: Volume - физический диск. Каждый volume может содержать 32 гигибайта (32 ГБ или 8x2 ^ 32 байта), (содержимое выравнивается по 8 байт).
*Data volume server*: этот сервис управляет несколькими *data volumes*. Среди них сервер тома данных хранит метаданные файлов, и файлами в томе данных можно управлять, обращаясь к метаданным файла (размер метаданных файла составляет всего 16 байт).
####PS: Data volume server -  управляет несколькими *data volumes*.
Фактические данные хранятся в *stored in volumes on storage nodes*. Один *volume server can have multiple volumes* и может поддерживать доступ для чтения и записи с базовой аутентификацией. One volume server* corresponds to *multiple volumes*.
The actual file metadata is stored in each volume on volume servers.
*Master server*: Управляет metadata information (data volume metadata). Все тома управляются главным сервером. Главный сервер содержит идентификатор тома для сопоставления сервера тома. Это довольно статичная информация, и ее легко кэшировать.

#### How to access the server dashboard?
SeaweedFS has web dashboards for its different services:

Master server dashboards can be accessed on http://hostname:port in a web browser.For example: http://localhost:9333.
Volume server dashboards can be accessed on http://hostname:port/ui/index.html.For example: http://localhost:8080/ui/index.html
Архитектура:
Данные храняться в VOLUME в серверах хранения. Один VOLUME SERVER может иметь несколько VOLUMES.
Все тома управляются MAIN MASTER SERVER. MAIN MASTER SERVER содержит идентификатор тома для сопоставления сервера тома. Это довольно статичная информация, и ее легко кэшировать.
Запись/Чтение:
Когда клиент отправляет запрос на запись, главный сервер возвращает (идентификатор тома, ключ файла, файл cookie, URL-адрес узла тома) для файла. Затем клиент связывается с узлом тома и отправляет содержимое файла POST.
Когда клиенту необходимо прочитать файл на основе (идентификатор тома, ключ файла, файл cookie), он запрашивает у главного сервера идентификатор тома для (URL-адрес узла тома, общедоступный URL-адрес узла тома) или извлекает его из кеша. Затем клиент может ПОЛУЧИТЬ контент или просто отобразить URL-адрес на веб-страницах и позволить браузерам получать контент.

#### Storage Size
In the current implementation, each volume can hold 32 gibibytes (32GiB or 8x2^32 bytes). This is because we align content to 8 bytes. We can easily increase this to 64GiB, or 128GiB, or more, by changing 2 lines of code, at the cost of some wasted padding space due to alignment.
There can be 4 gibibytes (4GiB or 2^32 bytes) of volumes. So the total system size is 8 x 4GiB x 4GiB which is 128 exbibytes (128EiB or 2^67 bytes).
Each individual file size is limited to the volume size.

Problems
* seaweedfs uses synchronous replication with the following problems:
   a. There is no automatic synchronization mechanism when a volume-server goes offline and goes online.
   b. Synchronous replication needs to wait for each node to rewrite successfully, and the efficiency is relatively low
   c. Although the node's upper and lower lines will quickly notify the master node through the heartbeat, there is still a certain delay. During the period when the Volume-Server is overwritten, the upload failure may occur due to the volume-server that has been offline.
 * Seaweedfs is currently relatively weak in terms of rights management. Currently there is only one whitelist control mechanism to control external read/write permissions/malicious deletion.


REPLICATION TABLE
Volume number and maximum storage
The default maximum is 7, you can set 100 and so on. . .
volume backup mechanism Replication
000: no replication, only one copy of data, *Default*
001: replicate once on the same rack (стойка)
010: replicate once on a different rack(стойка), but same data center
100: replicate once on a different data center
200: replicate twice on two different data center
110: replicate once on a different rack, and once on a different data center

type is xyz:
x Number of backup copies in other data centers
y The number of different racks backups in different data centers
z The number of backup copies of the same rack on other servers

PORTS:
9333 - master
8080 - volume nodes

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
