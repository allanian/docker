```
datastore_id         = var.datastore != "" ? data.vsphere_datastore.datastore[0].id : null

if(var.datastore != "")
  data.vsphere_datastore.datastore[0].id
else
  null
```
