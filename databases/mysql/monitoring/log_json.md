```
# mysql  json logs - # install component
mysql
install component 'file://component_log_sink_json';
select * from mysql.component where component_urn like '%json%'\G
# enable json service
```
```
log_filter_interval : Implements filtering based on log event priority and error code, in combination with the log_error_verbosity and log_error_suppression_list system variable
log_sink_json : Implements the JSON logging in error log
# check
select @@log_error_services;
# enable json
set global log_error_services = 'log_filter_internal; log_sink_json';
quit

# now you can check file 
/var/log/mysql/mysql-error.log.00.json
```

# Uninstall component

```
uninstall component 'file://component_log_sink_json';
set global log_error_services='log_filter_internal; log_sink_internal';


ls -la /var/log/mysql/
-rw-r-----   1 mysql mysql        0 Jun 17 11:52 mysql-error.log.00.json

# nano /etc/my.cnf
[mysqld]
log_error_services='log_filter_internal; log_sink_internal; log_sink_json'


# INSTALL TD_AGENT_BIT
yum install td-agent-bit

```
