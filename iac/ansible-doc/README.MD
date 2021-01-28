## Conditionals IF/ELSE
```{% if vault.backend == 'consul' -%}
  {% include vault.backend_consul with context -%}
{% elif vault.backend == 'file' -%}
  {% include vault.backend_file with context -%}
{% endif %}
```
