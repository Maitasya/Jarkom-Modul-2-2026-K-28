#!/bin/sh

DOMAIN="abbey.k28.com"

echo "=== SOAL 18: DNS TTL & Sinkronisasi ==="

echo ""
echo "=== 1. Cek SOA PRAB ==="
dig @192.225.5.2 k28.com SOA +short

echo ""
echo "=== 2. Cek A RECORD ABBEY di PRAB ==="
dig @192.225.5.2 "$DOMAIN" A +noall +answer

echo ""
echo "=== 3. Cek SOA TEDD ==="
dig @192.225.5.3 k28.com SOA +short

echo ""
echo "=== 4. Cek A RECORD ABBEY di TEDD ==="
dig @192.225.5.3 "$DOMAIN" A +noall +answer

echo ""
echo "=== 5. Validasi ZONE ==="
named-checkzone k28.com /var/bind/k28.com

echo ""
echo "=== SOAL 18 SELESAI ==="
