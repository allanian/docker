https://github.com/allanian/docker/blob/master/logging/efk/doc/readme.md#troubles-problems-in-elasticsearch
https://github.com/allanian/docker/blob/master/logging/efk/doc/readme.md#optimization-elk

# TROUBLES, PROBLEMS IN ELASTICSEARCH
#### EXCLUDE MULTIPLE on vizualization
10.10.0.20|10.10.0.85

#### как сменить INDEX PATTERN у Visualization
```
создаем новую Visualization такого же типа, как и существующая
В URL копируем ID of Visualization
Переходим в существующую-старую Visualization и копируем весь URL
Заменяем в полном URL, ID of Visualization на ID of Visualization новой Visualization, которую мы создали.
https://efk.company.ru/app/visualize#/edit/08d543f0-8d4b-11eb-a99a-8db819cf22bf?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15h,to:now))&_a=(filters:!(),linked:!f,query:(language:kuery,query:''),uiState:(),vis:(aggs:!(),params:(annotations:!((color:%23F00,fields:'',icon:fa-tag,id:'5835c840-6490-11eb-889b-bb63fc856413',ignore_global_filters:1,ignore_panel_filters:1,index_pattern:'*',query_string:(language:kuery,query:''),template:'')),axis_formatter:number,axis_position:left,axis_scale:normal,background_color:'rgba(255,255,255,1)',background_color_rules:!((id:'9b52b890-6490-11eb-889b-bb63fc856413')),bar_color_rules:!((id:'9c3eed50-6490-11eb-889b-bb63fc856413')),default_index_pattern:'td.rv-frt*',default_timefield:'@timestamp',filter:(language:kuery,query:'status_code%20%3E%3D%20500'),gauge_color_rules:!((id:'9d8fd750-6490-11eb-889b-bb63fc856413')),gauge_inner_width:10,gauge_style:half,gauge_width:10,id:'61ca57f0-469d-11e7-af02-69e470af7417',index_pattern:'td.rv-frt*',interval:'',isModelInvalid:!f,series:!((axis_position:right,chart_type:line,color:'rgba(185,46,18,1)',fill:0.5,formatter:number,id:'61ca57f1-469d-11e7-af02-69e470af7417',label:'',line_width:1,metrics:!((id:'61ca57f2-469d-11e7-af02-69e470af7417',type:count)),point_size:1,separate_axis:0,split_color_mode:kibana,split_mode:everything,stacked:none,type:timeseries)),show_grid:1,show_legend:1,time_field:'@timestamp',tooltip_mode:show_all,type:timeseries),title:'%5BRV-FRONT%5D%20Code%205XX%20',type:metrics))
08d543f0-8d4b-11eb-a99a-8db819cf22bf
Переходим по этому URL и сохраняем с новым именем.
```
#### No cached mapping for this field. Refresh field list from Management => Index Patterns page
идем в management=>index pattern
находим наш индекс паттерн и нажимаешь refresh field list сверху справа

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
#### The length of [Object_Xml] field of doc of  index has exceeded [1000000]
```
PUT /object_versions_log-*/_settings
{
    "index" : {
        "highlight.max_analyzed_offset" : 6000000
    }
}
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
|Phase|Option|
|--|--|
|Name|lifecycle-policy|
| Hot phase    | Required - Advanced => Use recommended defaults => включить Delete Phase если нужно |
| Warm phase   | Enable 30d => Shrink index [1] => Force merge [1] |
| Cold phase   | Enable 60d |
| Delete phase | Enable 180d from index creation |
after all, click **Save**

#### ** Policy CLI**
go to Menu => Dev tools
```
PUT _ilm/policy/lifecycle-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "30d",
            "max_size": "50gb"
          },
          "set_priority": {
            "priority": 100
          }
        },
        "min_age": "0ms"
      },
      "warm": {
        "min_age": "30d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "shrink": {
            "number_of_shards": 1
          },
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "cold": {
        "min_age": "60d",
        "actions": {
          "set_priority": {
            "priority": 0
          }
        }
      },
      "delete": {
        "min_age": "180d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```
### 2.  Index Component Template
Menu => Stack Management => Index management => Component templates => Create template
```
Name| lifecycle-component-template
# index settings
{
  "lifecycle": {
    "name": "lifecycle-policy"
  },
  "number_of_shards": "1",
  "number_of_replicas": "1"
}

#### api

PUT _component_template/lifecycle-component-teplate
{
  "template": {
    "settings": {
      "lifecycle": {
        "name": "lifecycle-policy"
      },
      "number_of_shards": "1",
      "number_of_replicas": "1"
    }
  }
}
```
### 3. Index template
Menu => Stack Management => Index management => Index template => Create template
```
Name lifecycle-index-template
Index patterns - docker* td*
Component templates  lifecycle-component-teplate
# api
PUT _index_template/lifecycle-index-template
{
  "priority": 100,
  "index_patterns": [
    "docker*",
    "td*",
    "k8s*",
    "demodev*"
  ],
  "composed_of": [
    "lifecycle-component-teplate"
  ]
}

```
### 4. Применение шаблона ко всем существующим индексам
```
PUT td*/_settings
{
  "index.lifecycle.name": "lifecycle-policy" 
}

td*/_ - index pattern name
```
### 5. CHECK policy
```
GET td*/_ilm/explain
```








PUT _template/rotation-template-dev            – имя шаблона
"index.lifecycle.name": "rotation-policy-dev"   – имя политики
"index_patterns": ["docker*"],   - index pattern name
```

