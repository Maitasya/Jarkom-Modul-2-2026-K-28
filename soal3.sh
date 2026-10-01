#!/bin/sh

echo "=== SOAL 3 $(hostname) ==="

echo "[1] RESOLVER"
cat /etc/resolv.conf

echo
echo "[2] DEFAULT GATEWAY"
ip route | grep default

echo
echo "[3] CEK GATEWAY"
GW=$(ip route | awk '/default/ {print $3; exit}')
ping -c 3 "$GW"

echo
echo "[4] CEK LINTAS JARINGAN"
ping -c 3 192.225.5.2

echo
echo "[5] CEK DNS"
ping -c 3 google.com

echo "=== SELESAI ==="