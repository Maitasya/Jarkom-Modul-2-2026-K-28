cat > soal11_abbey.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx

cat > /etc/nginx/http.d/default.conf <<'NGINX'
upstream core_backend {
    server 192.225.5.6;
    server 192.225.5.7;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

nginx -t || exit 1

nginx 2>/dev/null || nginx -s reload

echo "=== TEST OBLADA ==="
wget -q -O- http://192.225.5.6/
echo

echo "=== TEST MOLLY ==="
wget -q -O- http://192.225.5.7/
echo

echo "=== HEADER ==="
grep -E 'proxy_set_header (Host|X-Real-IP)' /etc/nginx/http.d/default.conf

echo "=== LOAD BALANCING ==="

for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done

echo "=== SOAL 11 ABBEY SELESAI ==="
EOF

chmod +x soal11_abbey.sh
./soal11_abbey.sh