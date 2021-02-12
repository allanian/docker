# get all logs from RABBITMQ
```
on rabbitmq server create user logstash with access to read,write,configure to vhost.
```
### install logstash and configure it
```
What you need is just three things:

An exchange for the application to publish messages to.
A queue for LogStash to consume messages from.
A binding between that exchange and that queue; the queue will get a copy of every message published to the exchange with a matching routing key.
So, for each of the three things (the exchange, the queue, and the binding) you need to:

Decide a name
Decide if you're creating it, or letting LogStash create it
Configure everything to use the same name
```
```
/etc/logstash/conf.d/rabbitmq.conf
# EXAMPLE OF INPUT
input {
  rabbitmq {
    id => "rabbitmyq_id"
    # connect to rabbit
    host => "rabbitmq01"
    port => 5672
    user => "logstash"
    password => "logstash"
    vhost => "/"
    # Consume from existing queue of APP
    queue => "put_object_version"
    durable => "true"
    # No ack will boost your perf
    ack => false
  }
}

# EXAMPLE OF INPUT - you could create just the logs exchange, and let LogStash create the queue and binding, like this:
input {
  rabbitmq {
    id => "rabbitmyq_id"
    # connect to rabbit
    host => "localhost"
    port => 5672
    vhost => "/"
    # Create a new queue
    queue => "logstash_processing_queue"
    durable => "true"
    # Take a copy of all messages with the "app_version_queue" routing key from the existing exchange
    exchange => "logs"
    key => "app_version_queue"
    # No ack will boost your perf
    ack => false
  }
}

# you could let LogStash create all of it, and make sure your application publishes to the right exchange:
input {
  rabbitmq {
    id => "rabbitmyq_id"
    # connect to rabbit
    host => "localhost"
    port => 5672
    vhost => "/"
    # Create a new queue
    queue => "logstash_processing_queue"
    durable => "true"
    # Create a new exchange; point your application to publish here!
    exchange => "log_exchange"
    exchange_type => "direct"
    # Take a copy of all messages with the "app_version_queue" routing key from the new exchange
    key => "app_version_queue"
    # No ack will boost your perf
    ack => false
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
