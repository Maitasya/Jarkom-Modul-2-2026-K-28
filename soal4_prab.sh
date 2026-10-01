cat > /root/soal4_prab.sh <<'EOT'
#!/bin/sh
echo "=== Konfigurasi DNS PRAB - K28 ==="

DOMAIN="k28.com"
IP_PRAB="192.225.5.2"
IP_TEDD="192.225.5.3"
IP_PENNY="192.225.3.3"

apk update
apk add bind bind-tools

cat > /etc/bind/named.conf <<EOF
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";
    listen-on { 127.0.0.1; $IP_PRAB; };
    listen-on-v6 { none; };
    forwarders { 192.168.122.1; };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    dnssec-validation no;
};

zone "$DOMAIN" IN {
    type master;
    file "/var/bind/$DOMAIN";
    notify yes;
    also-notify { $IP_TEDD; };
    allow-transfer { $IP_TEDD; };
};
EOF

cat > /var/bind/$DOMAIN <<EOF
\$TTL 604800
@   IN  SOA prab.$DOMAIN. root.$DOMAIN. (
            $(date +%s)  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.$DOMAIN.
@       IN  NS  tedd.$DOMAIN.
prab    IN  A   $IP_PRAB
tedd    IN  A   $IP_TEDD
@       IN  A   $IP_PENNY
EOF

mkdir -p /var/run/named
chown named:named /var/run/named

echo "=== Cek konfigurasi ==="
named-checkconf /etc/bind/named.conf
named-checkzone $DOMAIN /var/bind/$DOMAIN

echo "=== Jalankan named ==="
pkill named 2>/dev/null
sleep 1
named -u named
echo "=== Selesai ==="
EOT
chmod +x /root/soal4_prab.sh