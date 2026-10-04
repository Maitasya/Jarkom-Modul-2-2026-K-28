#!/bin/sh

apk add php84 php84-fpm

php-fpm84 -D

mkdir -p /var/www/eternal

cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "Eternal PHP OK";
?>
PHP

cat > /etc/apache2/conf.d/eternal.conf <<'APACHE'
ProxyPass "/eternal" "!"

Alias /eternal/ /var/www/eternal/

<Directory "/var/www/eternal">
    Options Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
APACHE

httpd -t && httpd -k restart

echo "=== Soal 15 Penny selesai ==="
