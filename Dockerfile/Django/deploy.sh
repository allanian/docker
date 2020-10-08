export host_port=8015
export env=${bamboo.inj.env}
export app_name=${bamboo.inj.app_name}
export version=${bamboo.inj.version}
mkdir -p /data/django/{static,media}
cp nginx/nginx.conf /data/django/nginx.conf 

# OR WE CAN USE CDN for static
# Deploy
${bamboo.docker_login}
${bamboo.docker_compose_deploy}