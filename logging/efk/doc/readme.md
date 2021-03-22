# Optimization ELK
# COMPRESS INDEX
Menu => Index management => Select index => click in menu Close index => click in menu Edit index settings
"codec": "best_compression",
Save
Open index
при изменении кодека для индекса только новые сегменты (после новой индексации, изменений в существующих документах или слияния сегментов) будут использовать новый кодек.

# FORCE MERGE
Menu => Index management => Select index => Click Force merge
Работает по аналогии дефрагментации
Освобождает удаленные блоки, и уменьшит размер индекса

# LIFEPOLICY

## 1. Policy
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
## 2.  Template

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
## 3. Применение шаблона ко всем существующим индексам
```
PUT object_versions_test_log-*/_settings
{
  "index.lifecycle.name": "policy-object-vers-test" 
}

object_versions_test_log-*/_ - index pattern name
```
## 4. CHECK policy
```
GET object_versions_test_log-*.*/_ilm/explain
```
