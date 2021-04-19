# SENTRY ONPREMISE DOCKER
```
cd /data/sentry
docker-compose exec worker bash
# очистка всех данных о событиях за 30 дней. (шло 2часа)
sentry cleanup --days 30
# После этого мы заходим в базу данных, запустив эти
docker-compose exec postgres bash
psql -U postgres
# VACUUM FULL блокирует таблицы в db, пока операция не закончиться.
VACUUM FULL; 
```
