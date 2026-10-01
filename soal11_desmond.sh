cat > soal11_desmond.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx

mkdir -p /var/lib/nginx/html

echo '<h1>DESMOND - VAULT</h1>' > /var/lib/nginx/html/index.html

cat > /etc/nginx/http.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        root /var/lib/nginx/html;
        index index.html;
    }
}
NGINX

nginx -t || exit 1
nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 11 DESMOND SELESAI ==="
wget -q -O- http://127.0.0.1/
echo
EOF

chmod +x soal11_desmond.sh
./soal11_desmond.sh
