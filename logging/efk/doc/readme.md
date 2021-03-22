
https://github.com/allanian/docker/blob/master/logging/efk/doc/readme.md#optimization-elk

# TROUBLES, PROBLEMS IN ELASTICSEARCH

#### max virtual memory areas vm.max_map_count [65530] is too low, increase to at least
Решение
sudo sysctl -w vm.max_map_count=262144
grep vm.max_map_count /etc/sysctl.conf
vm.max_map_count=262144
#### low disk watermark [??%] exceeded on
Срабатывает когда места на диске мало.
add this to elasticsearch.yml and restart it
```
cluster.routing.allocation.disk.threshold_enabled: true
# first alert, when free of disk-size < 30gb 
cluster.routing.allocation.disk.watermark.low: 30gb
# second alert, when free of disk-size < 15gb 
cluster.routing.allocation.disk.watermark.high: 15gb
# stop ELK, when free of disk-size < 10gb 
cluster.routing.allocation.disk.watermark.flood_stage: 10gb
```
#### cannot allocate because allocation is not permitted to any of the nodes
```
curl 'elastic:QWE123qwe@localhost:9200/_cluster/health?pretty' -H 'Content-Type: application/json'
curl 'elastic:QWE123qwe@localhost:9200/_cluster/allocation/explain?pretty' -H 'Content-Type: application/json'
"decider" : "same_shard",
"explanation" : "a copy of this shard is already allocated to this node [[docker.site-back.rv-site-back01-2021.02.12][0], node[KUnFTdNnRF2F3WZqp-zonA], [P], s[STARTED], a[id=sIP9jCFSTa6ltlqRWHrRkQ]]"
NEED MORE THEN ONE NODE!
```
#### status RED
После рестарта статус RED
```
curl 'logstash:logstash@localhost:9200/_cluster/health?pretty' -H 'Content-Type: application/json'
http://elk.company.ru:9200/_cluster/health?pretty
{
  "cluster_name" : "test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1905,
  "active_shards" : 1905,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 1870,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.46357615894039
}

unassigned_shards – должна быть переведена в активные (хотя бы половина).
Тут можно поглядеть статус
http://elk.company.ru:9200/_cluster/allocation/explain?pretty

curl 'logstash:logstash@localhost:9200/_cluster/allocation/explain?pretty' -H 'Content-Type: application/json'
```

# Optimization ELK
## COMPRESS INDEX
Menu => Index management => Select index => click in menu Close index => click in menu Edit index settings
"codec": "best_compression",
Save
Open index
при изменении кодека для индекса только новые сегменты (после новой индексации, изменений в существующих документах или слияния сегментов) будут использовать новый кодек.

## FORCE MERGE
Menu => Index management => Select index => Click Force merge
Работает по аналогии дефрагментации
Освобождает удаленные блоки, и уменьшит размер индекса

## LIFEPOLICY

### 1. Policy
Go to ElasticSearch => Stack Management => Data => Index lifecycle policy => Create policy
**Dev policy**
|Phase|Option|
|--|--|
|Name|policy-object-vers-test|
| Hot phase    | disable |
| Warm phase   | disable |
| Cold phase   | disable |
| Delete phase | Activate delete phase |
**Timing for delete phase** – 30 – days from index creation
after all, click **Save**

#### ** Policy CLI**
go to Menu => Dev tools
```
PUT _ilm/policy/policy-object-vers-test
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": {
            "priority": 100
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {}
      }
    }
  }
}
```
### 2.  Template

Menu => Stack Management => Index management => Index templates => Create template
Name – rotation-template-ObjectVers
**Dev policy**
|Phase|Option|
|--|--|
|Name| template-object-vers-test |
| Index patterns | object_versions_test_log-* |


#### Click Next
**Index settings**
```
{
"index": {
"lifecycle": {
"name": "policy-object-vers-test"
},
"number_of_shards": "1",
"number_of_replicas": "1"
}
}
```
Click Next =>Save
#### ** Template CLI**
```
PUT _template/template-object-vers-test
{
  "index_patterns": ["object_versions_test_log-*"],                 
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "policy-object-vers-test"    
  }
}

PUT _template/template-object-vers-test             – имя шаблона
"index.lifecycle.name": "policy-object-vers-test"   – имя политики
"index_patterns": ["object_versions_test_log-*"],   - index pattern name
```
### 3. Применение шаблона ко всем существующим индексам
```
PUT object_versions_test_log-*/_settings
{
  "index.lifecycle.name": "policy-object-vers-test" 
}

object_versions_test_log-*/_ - index pattern name
```
### 4. CHECK policy
```
GET object_versions_test_log-*.*/_ilm/explain
```
