## Conditionals IF/ELSE
#### check var=value
```
{% if vault.backend == 'consul' -%}
  {% include vault.backend_consul with context -%}
{% elif vault.backend == 'file' -%}
  {% include vault.backend_file with context -%}
{% endif %}

# check var=true (include - paste all from external file)
{% if item.proxy_gluu|default(false, true) %}
        proxy_pass_header Authorization;
        proxy_pass  https://{{item.ip_port}};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;

        proxy_headers_hash_max_size 512;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
        client_max_body_size 0;
        proxy_read_timeout 36000s;
        proxy_ssl_session_reuse off;
        
{% else %}
        proxy_pass  http://{{item.ip_port}};
        include    /etc/nginx/ssl/proxy.conf;
{%endif %}
```

