# crontab
```
0 1 * * 0  docker exec -it git.rendez-vous.ru /opt/gitlab/embedded/bin/registry garbage-collect /var/opt/gitlab/registry/config.yml
0 1 * * * /opt/backup-script/backup.sh >> /tmp/backup_log.txt
```
