cat > soal10_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx php84 php84-fpm

mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d

cat > /var/www/core/index.php <<'PHP'
<?php
echo "<h1>Markas K28</h1>";
echo "<p>Halo! Selamat datang di markas kecil The Mesh.</p>";
echo "<p>Kalau error, tenang... kita juga kadang error.</p>";
echo "<p>Jangan panik, deadline cuma angka.</p>";
echo "<hr>";
echo "<p><b>May & AL | Kelompok K28</b></p>";
echo "<p>Dikelola oleh node: oblada</p>";
echo "<p><a href='/profil'>Lihat Profil Kami</a></p>";
?>
PHP

cat > /var/www/core/profil.php <<'PHP'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: oblada</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
PHP

cat > /etc/nginx/http.d/core.conf <<'NGINX'
server {
    listen 80;
    server_name oblada.k28.com;

    root /var/www/core;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }
}
NGINX

php-fpm84

nginx -t || exit 1

nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 10 OBLADA SELESAI ==="
EOF

chmod +x soal10_setup.sh
./soal10_setup.sh