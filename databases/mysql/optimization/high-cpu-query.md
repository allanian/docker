# 1. High cpu query
```
yum install sysstat -y
```
## get mysql pid
```
pidof mysqld
pidstat -t -p <mysqld_pid> 1
 параметр (-t), который меняет его вид с процесса (по умолчанию) на потоки  где он показывает связанные потоки в рамках данного процесса. 
 Мы можем использовать его, чтобы узнать, какой поток потребляет больше всего ЦП на нашем сервере. 
 Добавление параметра -p вместе с идентификатором процесса mysql, чтобы инструмент отображал только потоки MySQL, что упрощает устранение неполадок. 
 Последний параметр (1) - отображать одну выборку в секунду:
pidstat -t -p 2935 1
pidstat -t -p 10603 1
pidstat -t -p 3889 1
Linux 3.10.0-957.5.1.el7.x86_64 (rv-site-sql02.rendez-vous.ru) 	11/13/2020 	_x86_64_	(32 CPU)

04:06:37 PM   UID      TGID       TID    %usr %system  %guest    %CPU   CPU  Command
04:06:38 PM    27     10603         -  100.00   49.02    0.00  100.00    22  mysqld
04:06:38 PM    27         -     12527   87.25    1.96    0.00   89.22    12  |__mysqld
04:06:38 PM    27         -     22711   99.02    0.98    0.00  100.00    16  |__mysqld
Thread with id - 22711    100%
# connect to mysql
select * from performance_schema.threads where THREAD_OS_ID = 22711 \G
И вы получите запрос, где будет указан 
PROCESSLIST_USER – юзер, от которого запущен запрос
PROCESSLIST_HOST: 10.10.0.33 – хост, с которого пришел запрос
PROCESSLIST_COMMAND: Query – тип команды
PROCESSLIST_STATE: Creating sort index – что делает

Теперь мы знаем, что высокое потребление ЦП происходит из-за запроса в таблице joinit
```
