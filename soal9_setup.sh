 cat > soal9_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add apache2 curl

mkdir -p /arsip/laporan

echo "dokumen 1" > /arsip/dokumen1.txt
echo "dokumen 2" > /arsip/dokumen2.txt
echo "laporan a" > /arsip/laporan/a.txt
echo "dari obladi" > /arsip/server.txt

chmod -R 755 /arsip

cat > /etc/apache2/conf.d/arsip.conf <<'CONF'
ServerName localhost

Alias /arsip /arsip

<Directory "/arsip">
    Options +Indexes
    IndexOptions FancyIndexing HTMLTable NameWidth=*
    AllowOverride None
    Require all granted
</Directory>
CONF

httpd -t || exit 1

ps | grep -q "[h]ttpd" && httpd -k restart || httpd

sleep 1

echo "=== TEST APACHE ==="
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"

echo "=== TEST SERVER ==="
curl -s http://localhost/arsip/server.txt
EOF