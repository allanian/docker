proxy from reversy proxy nginx to nginx in nomad proxy

# SSL
```
ssl_certificate /etc/ssl/rv-ssl/company.cer;
ssl_certificate_key /etc/ssl/rv-ssl/company.key;
ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
#ssl_protocols TLSv1.1 TLSv1.2;
#ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:!ADH:!AECDH:!MD5;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA$
#ssl_session_cache shared:SSL_R_V:256m;
ssl_session_cache shared:SSL_R_V:100m;
ssl_session_timeout 1h;
ssl_prefer_server_ciphers on;
ssl_session_tickets on;
ssl_dhparam /etc/pki/tls/dh.pem;
add_header Strict-Transport-Security "max-age=63072000" always;
proxy_ssl_verify        on;
proxy_ssl_session_reuse off;
ssl_verify_client off;
proxy_ssl_server_name on;
ssl_buffer_size 14k;
ssl_trusted_certificate /etc/pki/tls/certs/ca-bundle.crt;

#HSTS
add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload';

# CSP -	problem!
#add_header Content-Security-Policy "default-src 'self'; font-src *;img-src * data:; script-src *; style-src *";

#  X-Frame-Options SAMEORIGIN - allow site use iframe
add_header X-Frame-Options "SAMEORIGIN";
# X-Content-Type-Options - guard for XSS-attacks
add_header X-Content-Type-Options nosniff;
# Referrer-Policy (origin or strict-origin) - when user click on button in your site , what send him to another site, its also give him 
## no-referrer: never send the Referer header
## same-origin: send referrer, but only on requests to the same origin
## strict-origin: send referrer to all origins, but only the URL sans path (e.g. https://example.com/)
## strict-origin-when-cross-origin: send full referrer on same origin, URL sans path on foreign origin
add_header Referrer-Policy "strict-origin";
# Permissions-Policy
add_header Permissions-Policy "geolocation=(),midi=(),sync-xhr=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self),payment=()";
```
