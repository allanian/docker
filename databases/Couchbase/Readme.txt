/opt/couchbase/bin/couchbase-cli rebalance --cluster=127.0.0.1:8091 --username=Administrator --password 'password' --server-remove=50.100.23.20

/opt/couchbase/bin/couchbase-cli failover -c 127.0.0.1:8091 \
--username Administrator \
--password 'password'  \
--server-failover 50.100.23.20:8091 --hard


# CLUSTER
couchbase-cli cluster-init -c 127.0.0.1 --cluster-username Administrator \
 --cluster-password 'password' --services data --cluster-ramsize 4096
 
# init cluster with name STG on server 23.239.16.213 
# The quotas are set to 2048MB, 1024MB, 1024MB, 1024MB and 1024MB respectively.
/opt/couchbase/bin/couchbase-cli cluster-init -c 127.0.0.1 --cluster-username Administrator \
 --cluster-password 'password' --services data,index,query,fts,analytics \
 --cluster-ramsize 2048 --cluster-index-ramsize 1024 \
 --cluster-eventing-ramsize 1024 --cluster-fts-ramsize 1024 \
 --cluster-analytics-ramsize 1024 --cluster-fts-ramsize 1024 \
 --cluster-name STG \
 --index-storage-setting default
 
## JOIN TO CLUSTER # need test more - don't worked
/opt/couchbase/bin/couchbase-cli server-add -c 127.0.0.1:8091 \
--username Administrator \
--password 'password' \
--server-add 50.100.23.20:8091 \
--server-add-username Administrator \
--server-add-password 'password' \
--services data,index,query,fts,analytics
  
  
###### BUCKETS
# services with priority - high
/opt/couchbase/bin/couchbase-cli bucket-create -c 127.0.0.1:8091 --username Administrator \
 --password 'password' --bucket services --bucket-type couchbase \
 --bucket-ramsize 200 --bucket-replica 2 --bucket-priority high \
 --bucket-eviction-policy fullEviction --enable-flush 1 \
 --enable-index-replica 1

 
 
# USERS
# GLUU ADMIN
/opt/couchbase/bin/couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator \
 -p 'password' --set --rbac-username gluu_admin --rbac-password 'password' \
 --rbac-name "Gluu Admin" --roles \
bucket_admin[gluu],bucket_admin[gluu_cache],bucket_admin[gluu_session],bucket_admin[gluu_site],bucket_admin[gluu_token],bucket_admin[gluu_user],\
query_select[gluu],query_select[gluu_cache],query_select[gluu_session],query_select[gluu_site],query_select[gluu_token],query_select[gluu_user],\
query_update[gluu],query_update[gluu_cache],query_update[gluu_session],query_update[gluu_site],query_update[gluu_token],query_update[gluu_user],\
query_insert[gluu],query_insert[gluu_cache],query_insert[gluu_session],query_insert[gluu_site],query_insert[gluu_token],query_insert[gluu_user],\
query_delete[gluu],query_delete[gluu_cache],query_delete[gluu_session],query_delete[gluu_site],query_delete[gluu_token],query_delete[gluu_user],\
query_manage_index[gluu],query_manage_index[gluu_cache],query_manage_index[gluu_session],query_manage_index[gluu_site],query_manage_index[gluu_token],query_manage_index[gluu_user] \
 --auth-domain local
# otp-services
/opt/couchbase/bin/couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator \
 -p 'password' --set --rbac-username otp-services --rbac-password 'tokenpassword' \
 --rbac-name "otp-services" --roles \
query_select[services],query_update[services],query_insert[services],query_delete[services] \
 --auth-domain local
 
#INDEXES
/opt/couchbase/bin/cbq -e http://localhost:8091 -u=Administrator -p='password' 
CREATE PRIMARY INDEX `services-primary-index` ON `services` WITH { "defer_build":true };
CREATE INDEX `email` ON `services`(`email`) WHERE `_type`="blockedmailentity" WITH { "defer_build":true };

# build
BUILD INDEX ON `services` (( SELECT RAW name FROM system:indexes WHERE keyspace_id = 'services' AND state = 'deferred' ));

