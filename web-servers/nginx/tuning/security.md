# Disable Content Sniffing
```
# add to http block
add_header X-Content-Type-Options nosniff;
```
# Limit or Disable Content Embedding
```
# add that to http block
# To disallow the embedding of your content from any domain other than your own, add the following line to your configuration:
add_header X-Frame-Options SAMEORIGIN;
# To disallow embedding entirely, even from within your own site’s domain:
add_header X-Frame-Options DENY;
```

# Cross-Site Scripting (XSS) Filter
```
# add that to http block
add_header X-XSS-Protection "1; mode=block";
```

# HTTP Strict Transport Security (HSTS)
```
# its disable http for site
# add that to http block
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

# Enforce Server-Side Cipher Suite Preferences
```
# add that to http block
ssl_prefer_server_ciphers on;
```
# Increase Keepalive Duration
```
# so minimizing the amount of handshakes which connecting clients need to perform will reduce your system’s processor use
# add that to http block
keepalive_timeout 75;
```
# Increase TLS Session Duration
```
# Maintain a connected client’s SSL/TLS session for 10 minutes before needing to re-negotiate the connection.
# add that to http block
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

# Enable HTTP/2 Support
```
# check openssl version - shoud be > 1.0.2
openssl version
# Add the http2 option to the listen directive in your site configuration’s server block for both IPv4 and IPv6. It should look like below:
listen    443 ssl http2;
listen    [::]:443 ssl http2;
# reload nginx
```
# OCSP Stapling
```
# add that to http block
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /root/certs/example.com/cert.crt;

# to verify
openssl s_client -connect example.org:443 -tls1 -tlsextdebug -status
```

























