#!/bin/sh

ZONE="/var/bind/k28.com"
DOMAIN="outbound.k28.com"

echo "=== SOAL 19: CNAME outbound -> http.badssl.com ==="

echo ""
echo "=== 1. Validasi Zone ==="
named-checkzone k28.com "$ZONE"

echo ""
echo "=== 2. Cek CNAME ==="
dig @192.225.5.2 "$DOMAIN" CNAME +noall +answer

echo ""
echo "=== 3. Cek HTTP Domain Asli ==="
curl -I http://http.badssl.com

echo ""
echo "=== 4. Ambil Konten Domain Asli ==="
curl -s http://http.badssl.com > /tmp/badssl-asli

echo ""
echo "=== 5. Ambil Konten melalui CNAME ==="
curl -s -H "Host: http.badssl.com" http://"$DOMAIN" > /tmp/badssl-cname

echo ""
echo "=== 6. Bandingkan Konten ==="
if diff -q /tmp/badssl-asli /tmp/badssl-cname >/dev/null 2>&1; then
    echo "Konten IDENTIK"
else
    echo "Konten BERBEDA"
fi

echo ""
echo "=== SOAL 19 SELESAI ==="
