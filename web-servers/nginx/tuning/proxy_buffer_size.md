# Identify your header size
```
curl -s -w \%{size_header} -o /dev/null https://site.com
879
curl -s -w \%{size_header} -o /dev/null http://localhost -H "Host: site.com"
240

if we got 9000, we need increase proxy_buffer_size
on linux get page size:
getconf PAGESIZE
default - 4096
So aligning 9000 to 4k chunks, we get 12k:
proxy_buffer_size 12k;
```
