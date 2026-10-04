#!/bin/sh

ZONE="/var/bind/k28.com"

# Update serial SOA
sed -i 's/1790762978/1790762979/' "$ZONE"

# Tambahkan TXT record jika belum ada
grep -q '^alpha[[:space:]].*TXT' "$ZONE" || cat >> "$ZONE" <<'EOF'

alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF

# Validasi zone
named-checkzone k28.com "$ZONE"

# Jalankan BIND jika belum aktif
if ! pgrep -x named >/dev/null 2>&1; then
    named -c /etc/bind/named.conf
else
    kill -HUP "$(pgrep -xo named)"
fi

echo "=== Soal 17 selesai ==="
