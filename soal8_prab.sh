cat > /root/soal8_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (prab) ==="

CONF="/etc/bind/named.conf"
SERIAL=$(date +%s)

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa; do
    if ! grep -q "zone \"$z\"" $CONF; then
        cat >> $CONF <<EOF

zone "$z" IN {
    type master;
    file "/var/bind/$z";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};
EOF
    fi
done

mkzone() {
    # $1 = zona, $2 = isi PTR
    cat > /var/bind/$1 <<EOF
\$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            $SERIAL  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
$2
EOF
}

mkzone 3.225.192.in-addr.arpa "3   IN  PTR penny.k28.com."
mkzone 4.225.192.in-addr.arpa "2   IN  PTR abbey.k28.com."
mkzone 5.225.192.in-addr.arpa "4   IN  PTR vault.k28.com.
5   IN  PTR vault.k28.com.
6   IN  PTR core.k28.com.
7   IN  PTR core.k28.com."

echo "=== Cek konfigurasi ==="
named-checkconf $CONF || exit 1
for z in 3 4 5; do
    named-checkzone $z.225.192.in-addr.arpa /var/bind/$z.225.192.in-addr.arpa || exit 1
done

echo "=== Muat ulang named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "=== Tes reverse di prab ==="
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
    echo -n "$ip: "
    dig @192.225.5.2 -x $ip +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_prab.sh
/root/soal8_prab.sh\