#!/bin/sh
echo "=== Soal 7: vault, core, CNAME ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

for h in vault core www static; do
    sed -i "/^$h[[:space:]]/d" $ZONA
done

cat >> $ZONA <<'EOF'
vault   IN  A      192.225.5.4
vault   IN  A      192.225.5.5
core    IN  A      192.225.5.6
core    IN  A      192.225.5.7
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF

sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" $ZONA

named-checkzone k28.com $ZONA || exit 1
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.2 $h.k28.com +short
done
echo "=== Isi zona ==="
grep -E "^(vault|core|www|static)" $ZONA
echo "=== Serial SOA ==="
dig @192.225.5.2 k28.com SOA +short
echo "=== Selesai ==="
EOT
chmod +x /root/soal7_prab.sh
/root/soal7_prab.sh