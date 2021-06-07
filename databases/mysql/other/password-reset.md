```
Процедура восстановления забытого пароля, сброс на новый:
Останавливаем сервис:
service mysql stop
Запускаем в безопасном режиме с пропуском таблиц привилегий:
mysqld_safe --skip-grant-tables &
Подключаемся к СУБД
mysql -u root
Обновляем пароль на новый:
update mysql.user set password = password ('newpassword') where user='root';
Обновим кэш привилегий:
flush privileges;
Выйдем из режима:
quit;
Остановим службу и запустим в обычном режиме:
service mysql stop
service mysql start
```
