```

ЕСЛИ вылетит эта ошибка
ERROR 1872 (HY000): Slave failed to initialize relay log info structure from the repository
STOP SLAVE;
RESET SLAVE;
CHANGE MASTER TO MASTER_HOST = 'rv-site-sql01', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'Ax1!SD@dd3s', MASTER_LOG_FILE = 'mysql-bin.013851', MASTER_LOG_POS = 765893607;
START SLAVE;
SHOW SLAVE STATUS \G


# решение
Could not execute Update_rows event on table rendez_vous.user_bin; Can't find record in 'user_bin', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the event's master log mysql-bin.013851, end_log_pos 2774
mysql-bin.013851
идем на мастер в папку с бин.логами и ищем лог с именем mysql-bin.013851 - он поврежден
решение это сменить позицию на +1 на слейве 2774+1=2775
CHANGE MASTER TO MASTER_HOST = 'rv-site-sql01', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'Ax1!SD@dd3s', MASTER_LOG_FILE = 'mysql-bin.013851', MASTER_LOG_POS = 2775;
Не помогло, пытался залить бэкап на слэйв сразу - ошибка тоже
mysqlbinlog /tmp/mysql-bin.013851 | mysql -uroot -p'Wah0baiL'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1032 (HY000) at line 214: Can't find record in 'user_bin'
 head -n 215 /tmp/mysql-bin.013851 | grep 'user_bin'

```
