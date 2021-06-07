# 1. Slow query configuration
mysql -u root -p
# check slow_query_log enabled
show global variables like 'slow%log%';
| slow_query_log                    | ON                      |
| slow_query_log_always_write_time  | 10.000000               |
| slow_query_log_file               | /var/log/mysql-slow.log

# Install Percona Tuner
sudo yum install percona-toolkit –y
# Report the slowest queries from mysql-slow.log:
pt-query-digest /var/log/mysql-slow.log --log_slow_verbosity=full > slowlog.txt
Calls - количество раз вызова этого скрипта
Все запросы отсортированы по общему времени выполнения time. Оптимизировать запросы нужно в таком же порядке — это даст наибольший эффект. 
Кроме этого обратите внимание на колонку R/Call — там указано среднее время выполнения одного запроса. 
В примере у второго запроса это время больше 9 секунд, следует выяснить причины.
После этого в отчете можно увидеть детальный профиль каждого запроса:

# Profile
# Rank Query ID                      Response time    Calls R/Call  V/M   
# ==== ============================= ================ ===== ======= ===== 
#    1 0x48B9E3C78866365009F407A3... 33777.8841 11.8%   988 34.1881  6.64 SELECT catalog_models
#    2 0x0EBEE8532D61AED456924686... 27841.0176  9.7%   854 32.6007  5.81 SELECT catalog_model
##### запрос 1
median - exec-time - среднее время выполнения запроса 33s
count - количество раз выполнения
