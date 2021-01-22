#!/bin/bash
docker exec -t gitlab gitlab-backup create;
#docker exec -t gitlab gitlab-backup create SKIP=registry;
docker exec -t gitlab gitlab-ctl backup-etc /var/opt/gitlab/backups;
rsync -azP --no-perms -0 --no-o --no-g /srv/gitlab/data/backups/ /mnt/remote_backups;
# delete local backups
find "/srv/gitlab/data/backups/" -maxdepth 1 -type f -mmin +$((60*23)) -name '*.tar' -delete;
