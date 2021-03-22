```
RabbitMQ ‒ это брокер сообщений. Его основная цель ‒ принимать и отдавать сообщения.
Producer (поставщик) ‒ программа, отправляющая сообщения. В схемах он будет представлен кругом с буквой «P»:
 Queue (очередь) ‒ имя «почтового ящика». Она существует внутри RabbitMQ. Хотя сообщения проходят через RabbitMQ и приложения, хранятся они только в очередях. 
 Очередь не имеет ограничений на количество сообщений, она может принять сколь угодно большое их количество ‒ можно считать ее бесконечным буфером. 
 Любое количество поставщиков может отправлять сообщения в одну очередь, также любое количество подписчиков может получать сообщения из одной очереди. 
 Consumer (подписчик) ‒ программа, принимающая сообщения. Обычно подписчик находится в состоянии ожидания сообщений. 
 ПРИМЕР:
 Exchange (точка обмена)
 routing_key - Имя очереди должно быть определено в параметре routing_key
# USERS
rabbitmq-plugins enable rabbitmq_management
# ADMIN
#Add a new/fresh user, say user test and password test:
rabbitmqctl add_user test test
#Give administrative access to the new user:
rabbitmqctl set_user_tags test administrator
#Set permission to newly created user:
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

# READ ONLY USER
rabbitmqctl add_user elastic elastic
# permissions on Configure/Write/Read
rabbitmqctl set_permissions  -p / elastic "" "" ".*"
rabbitmqctl set_user_tags elastic monitoring



go to web console 
create new queue elastic_queue










wget http://localhost:15672/cli/rabbitmqadmin
Make a virtual host and Set Permissions
rabbitmqctl add_vhost Some_Virtual_Host
rabbitmqctl set_permissions -p Some_Virtual_Host elastic ".*" ".*" ".*"

#Exchange - обменник, здесь сообщения сортируются и отправляются в нужные очереди
#Make an Exchange
./rabbitmqadmin declare exchange --vhost=Some_Virtual_Host name=some_exchange type=direct
Make a Queue
.rabbitmqadmin declare queue --vhost=Some_Virtual_Host name=some_outgoing_queue durable=true
QUEUE
# list
sudo rabbitmqctl list_queues
```


```
# RABBIT=>LOGSTASH=ELASTIC
on rabbit server
rabbitmqctl list_users
rabbitmqctl list_vhosts

# create user
rabbitmqctl add_user elastic2 elastic2
# permissions on Configure & READ ( ".*" "" ".*" // Configure/Write/Read)
rabbitmqctl set_permissions  -p / elastic2 ".*" "" ".*"
rabbitmqctl set_user_tags elastic2 monitoring


# delete user
rabbitmqctl delete_user elastic
```


```
FAQ
система отправляет сообщения в exchange,
потом сообщение копируется во все очереди, которые привязаны к этому EXCHANGE
Очередь должна иметь CONSUMER (слушатель), иначе сообщения в этой очереди будут копиться!!! и храниться на диске.
Диагностика:
Забивается место на диске с rabbitmq
Идем в Admin console rabbitmq
Сортируем по количеству сообщений
Проваливаемся в эту очередь
Смотрим наличие Consumer (слушатель)
Смотрим Bindings (exchange)

Если Consumer пустой, значит сообщениям некуда уходить.
Если очередь неактуальна жмем unbind.
Если актуально решаем проблемы с Consumer.
```

```
APP=>RABBITMQ=>LOGSTASH=>ELK

1) EXCHANGE - обменник для публикации сообщений от приложения
Exchange — обменник или точка обмена. В него отправляются сообщения. 
Exchange распределяет сообщение в одну или несколько очередей. 
Direct exchange — используется, когда нужно доставить сообщение в определенные очереди. 
Сообщение публикуется в обменник с определенным ключом маршрутизации и попадает во все очереди, которые связаны с этим обменником аналогичным ключом маршрутизации. 
Ключ маршрутизации — это строка. Поиск соответствия происходит при помощи проверки строк на эквивалентность.
Он маршрутизирует сообщения в очередь на основе созданных связей (bindings) между ним и очередью.
2) QUEUE - место где приложение получит сообщения
3) BINDING - связь между exchange и queue; очередь получит копию каждого сообщения, которое опубликовано в EXCHANGE по совпадающему ROUTING KEY
```
