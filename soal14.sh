#!/bin/sh

echo "=== SOAL 14 - ACCESS LOG ==="

cat > /etc/nginx/http.d/realip-log.conf <<'EOL'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOL

echo "[1] Cek konfigurasi Nginx..."
nginx -t || exit 1

echo "[2] Reload Nginx..."
nginx -s reload

echo "[3] Cek port 80..."
ss -ltnp | grep ':80'

echo "[4] Access log terakhir..."
tail -n 1 /var/log/nginx/access.log

echo "=== SOAL 14 SELESAI ==="
