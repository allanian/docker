export host_port=8015
export env=${bamboo.inj.env}
export app_name=${bamboo.inj.app_name}
export version=${bamboo.inj.version}
mkdir -p /data/django/{static,media}
# before all steps copy static folder to path
cp nginx/nginx.conf /data/django/nginx.conf 
# Deploy
${bamboo.docker_login}
${bamboo.docker_compose_deploy}
#${bamboo.docker_stack_deploy}