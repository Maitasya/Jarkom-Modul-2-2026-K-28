cat > /root/soal5_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 5: A record semua entitas ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

# Hapus record lama supaya tidak dobel kalau script dijalankan ulang
for h in rootkit alpha beta gamma delta epsilon abbey penny obladi desmond oblada molly; do
    sed -i "/^$h[[:space:]]/d" $ZONA
done

cat >> $ZONA <<'EOF'
rootkit IN  A   192.225.5.1
alpha   IN  A   192.225.1.2
beta    IN  A   192.225.1.3
gamma   IN  A   192.225.1.4
delta   IN  A   192.225.2.2
epsilon IN  A   192.225.2.3
abbey   IN  A   192.225.4.2
penny   IN  A   192.225.3.3
obladi  IN  A   192.225.5.4
desmond IN  A   192.225.5.5
oblada  IN  A   192.225.5.6
molly   IN  A   192.225.5.7
EOF

# Naikkan serial supaya tedd menarik zona baru
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" $ZONA

echo "=== Cek zona ==="
named-checkzone k28.com $ZONA || exit 1

echo "=== Muat ulang named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "=== Tes DNS ==="
for h in rootkit alpha beta gamma delta epsilon prab tedd abbey penny obladi desmond oblada molly; do
    echo -n "$h: "
    dig @192.225.5.2 $h.k28.com +short
done
echo -n "k28.com (apex): "
dig @192.225.5.2 k28.com +short
echo "=== Selesai ==="
EOT
chmod +x /root/soal5_prab.sh
/root/soal5_prab.sh