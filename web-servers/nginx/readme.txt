proxy from reversy proxy nginx to nginx in nomad proxy

# SSL
```
#HSTS
add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload';

# CSP -	problem!
#add_header Content-Security-Policy "default-src 'self'; font-src *;img-src * data:; script-src *; style-src *";

#  X-Frame-Options
add_header X-Frame-Options "SAMEORIGIN";
# X-Content-Type-Options
add_header X-Content-Type-Options nosniff;
# Referrer-Policy (origin or strict-origin)
add_header Referrer-Policy "strict-origin";
# Permissions-Policy
add_header Permissions-Policy "geolocation=(),midi=(),sync-xhr=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self),payment=()";
```
