```
yum install mysql-shell
mysqlsh
\connect root@localhost:3306
```
# 1. How to find the top three MySQL threads which consuming more memory for the particular user ?
```
\show threads --foreground -o tid,cid,user,memory,command,state,info,nblocking --order-by=memory --desc --where "user = 'artektiv'" --limit=3 
\show threads --foreground -o tid,cid,user,memory,command,state,info,nblocking --order-by=memory --desc --limit=3 

tid : thread id
cid : connection id
memory : the number of bytes allocated by the thread
started : time when thread started to be in its current state
user : the user who issued the statement, or NULL for a background thread
```
# 2. How to find the blocking and blocked threads ?
```
\show threads --foreground -o tid,cid,tidle,nblocked,nblocking,digest,digesttxt --where "nblocked=1 or nblocking=1"
```
# 3. How to find the top 10 threads, which used huge IO events ?
```
ioavgltncy : the average wait time per timed I/O event for the thread
ioltncy : the total wait time of timed I/O events for the thread
iomaxltncy : the maximum single wait time of timed I/O events for the thread
iominltncy : the minimum single wait time of timed I/O events for the thread
nio : the total number of I/O events for the thread

\show threads --foreground -o tid,ioavgltncy,ioltncy,iomaxltncy,iominltncy,nio --order-by=nio --desc  --limit=10
```
