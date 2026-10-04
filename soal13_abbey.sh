#!/bin/sh

# Membuat konfigurasi redirect Abbey
cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 80 default_server;
    server_name abbey.k28.com;

    return 302 http://static.k28.com/;
}
EOF

# Mengecek konfigurasi dan reload Nginx
nginx -t && nginx -s reload

echo "=== Soal 13 Abbey selesai ==="
