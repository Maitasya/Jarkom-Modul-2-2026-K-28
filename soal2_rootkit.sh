#!/bin/sh

echo "=== SOAL 2 : KONFIGURASI NAT ROOTKIT ==="

echo "[1] Aktifkan IP Forwarding"
sysctl -w net.ipv4.ip_forward=1

echo "[2] Aktifkan NAT MASQUERADE pada eth0"
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "[3] Cek IP Forwarding"
sysctl net.ipv4.ip_forward

echo "[4] Cek NAT"
iptables -t nat -L POSTROUTING -n -v

echo "=== SELESAI ==="
