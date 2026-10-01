cat > soal11_penny.sh <<'EOF'
#!/bin/sh

apk update
apk add apache2 apache2-openrc apache2-proxy

cat > /etc/apache2/conf.d/vault-proxy.conf <<'APACHE'
<Proxy "balancer://vault">
    BalancerMember "http://192.225.5.4"
    BalancerMember "http://192.225.5.5"
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPreserveHost On

ProxyPass "/" "balancer://vault/"
ProxyPassReverse "/" "balancer://vault/"

RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
APACHE

httpd -t -f /etc/apache2/httpd.conf || exit 1

echo "=== TEST OBLADI ==="
wget -q -O- http://192.225.5.4/
echo

echo "=== TEST DESMOND ==="
wget -q -O- http://192.225.5.5/
echo

echo "=== HEADER ==="
grep -E 'ProxyPreserveHost|X-Real-IP' /etc/apache2/conf.d/vault-proxy.conf

httpd -f /etc/apache2/httpd.conf

echo "=== LOAD BALANCING ==="

for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done

echo "=== SOAL 11 PENNY SELESAI ==="
EOF

chmod +x soal11_penny.sh
./soal11_penny.sh
