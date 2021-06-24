# delete job
nomad delete job
nomad stop -purge cms

# nomad status job
nomad status cms
nomad alloc logs 48aa4f69
nomad alloc status 48aa4f69
nomad job status -all-allocs -evals -verbose cms


