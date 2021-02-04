#!/bin/bash
docker exec -t gitlab gitlab-backup create SKIP=registry,pages,lfs;
docker exec -t gitlab gitlab-ctl backup-etc /var/opt/gitlab/backups;
rsync -azP --no-perms -0 --no-o --no-g /srv/gitlab/data/backups/ /mnt/remote_backups; 
# delete local backups
find "/srv/gitlab/data/backups/" -maxdepth 1 -type f -mmin +$((120)) -name '*.tar' -delete;
find "/mnt/remote_backups/" -maxdepth 1 -type f -mmin +$((120*192)) -name '*.tar' -delete;
