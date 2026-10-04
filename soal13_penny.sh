#!/bin/sh

# Mengaktifkan mod_rewrite
echo 'LoadModule rewrite_module /usr/lib/apache2/mod_rewrite.so' > /etc/apache2/conf.d/rewrite.conf

# Membuat konfigurasi redirect Penny
cat > /etc/apache2/conf.d/redirect.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k28.com

    RewriteEngine On
    RewriteRule ^/(.*)$ http://www.k28.com/$1 [R=301,L]
</VirtualHost>
EOF

# Mengecek konfigurasi dan restart Apache
httpd -t && httpd -k restart

echo "=== Soal 13 Penny selesai ==="
