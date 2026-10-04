#!/bin/sh

mkdir -p /var/www/orion

cat > /var/www/orion/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body>
<h1>Orion Static OK</h1>
<p>This is a static page.</p>
</body>
</html>
HTML

cat > /etc/nginx/http.d/default.conf <<'NGINX'
upstream core_backend {
    server 192.225.5.6;
    server 192.225.5.7;
}

server {
    listen 80;
    server_name core.k28.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80 default_server;
    server_name abbey.k28.com;

    location = /orion {
        return 301 /orion/;
    }

    location ~ ^/orion/.*\.php$ {
        return 404;
    }

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        return 302 http://static.k28.com/;
    }
}
NGINX

nginx -t && nginx -s reload

echo "=== Soal 15 Abbey selesai ==="
