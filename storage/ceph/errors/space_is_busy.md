```
Закончилось место – clickhouse backup
https://ceph-grafana.company.ru:3000/
Capasity used
Подключился через s3 браузер и почистил место, но на ceph это не отразилось, потому что он держит это в памяти.
Заходим на ceph01
1.	try running the garbage collector
list what will be deleted
radosgw-admin gc list --include-all

It will only clear/remove parts that are older then the time feild
radosgw-admin gc process

Форсирование чистки места после удаления 
Просмотр свободного места
ceph osd df tree


2.	if it didn't work (like for me with most of my data)
find the bucket with your data :
ceph df

Usually your S3 data goes in the default pool default.rgw.buckets.data
purge it from every object /!\ you will loose all your data /!\
rados purge default.rgw.buckets.data --yes-i-really-really-mean-it   
I don't know why ceph is not purging this data itself for now (still learning...).

```
