cat > /root/soal8_tedd.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (tedd) ==="

CONF="/etc/bind/named.conf"

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa; do
    if ! grep -q "zone \"$z\"" $CONF; then
        cat >> $CONF <<EOF

zone "$z" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/$z";
};
EOF
    fi
done

named-checkconf $CONF || exit 1

# Hapus salinan lama supaya selalu menarik versi terbaru dari prab
pkill named 2>/dev/null
sleep 1
rm -f /var/bind/slave/k28.com /var/bind/slave/*.in-addr.arpa
named -u named
sleep 4

echo "=== File slave ==="
ls /var/bind/slave

echo "=== Cek authoritative (harus ada aa) ==="
for s in 192.225.5.3 192.225.5.2; do
    echo "--- server $s ---"
    for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
        dig @$s -x $ip +noall +comments +answer | grep -E "^;; flags|PTR"
    done
done

echo "=== Serial SOA ==="
for z in 3 4 5; do
    dig @192.225.5.2 $z.225.192.in-addr.arpa SOA +short
    dig @192.225.5.3 $z.225.192.in-addr.arpa SOA +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_tedd.sh
/root/soal8_tedd.sh
