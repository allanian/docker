#!/bin/sh
if [ "$APP" = "app" ]
then
    echo "Waiting for mysql..." && while ! nc -vz db 3306; do sleep 0.1; done && echo "Mysql started" \
    && cd /var/www/app && php yii migrate --migrationNamespaces="common\modules\lb\migrations" --interactive=0
fi
#cd /var/www/app && chmod 0777 -R api/runtime backend/runtime backend/web/assets console/runtime frontend/runtime frontend/web/assets && chmod 0775 -R ./*yii
exec "$@"
