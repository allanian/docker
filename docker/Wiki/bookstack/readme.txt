migrate to another server
# backup mariadb
mysqldump -u root -p'bookstackpass' bookstackapp > bookstack.backup.sql
scp to another server

# up app
docker-compose up -d
# restore mariadb
mysql -uroot -p'bookstackpass' bookstackapp < bookstack.backup.sql