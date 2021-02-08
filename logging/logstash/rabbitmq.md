# get all logs from RABBITMQ
```
on rabbitmq server create user logstash with access to read,write,configure to vhost.
```
### install logstash and configure it
```
/etc/logstash/conf.d/rabbitmq.conf
input {
  rabbitmq {
    id => "rabbitmyq_id"
    # connect to rabbit
    host => "rabbitmq02"
    port => 5672
    user => "logstash"
    password => "logstash"
    # key - it's like name of queue - test
    key => "test"
    # exchange - should exist in rabbitmq
    exchange => logs
    durable => "true"
    # No ack will boost your perf
    #ack => false
  }
}

output {
# stdout for debug
#  stdout {
##    codec => json
#    codec => rubydebug
#  }
  elasticsearch {
    hosts => [ "127.0.0.1:9200" ]
    # index with date
    index => "index_name-%{+YYYY.MM.dd}"
    # user for auth to elastic, need create that user
    user => logstash
    password => logstash
  }
}


```
