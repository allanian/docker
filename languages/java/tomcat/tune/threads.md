https://community.jaspersoft.com/wiki/how-increase-maximum-thread-count-tomcat-level
```
server.xml
<connector connectiontimeout="20000"
           maxthreads="400"
           port="8080"
           protocol="HTTP/1.1"
           redirectport="8443" />
           ```
