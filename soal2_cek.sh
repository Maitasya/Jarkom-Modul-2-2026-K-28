#!/bin/sh

echo "=== SOAL 2 CEK $(hostname) ==="

echo "[1] RESOLVER"
cat /etc/resolv.conf

echo
echo "[2] DEFAULT GATEWAY"
ip route | grep default

echo
echo "[3] PING GATEWAY"
GW=$(ip route | awk '/default/ {print $3; exit}')
ping -c 3 "$GW"

echo
echo "[4] PING INTERNET"
ping -c 3 8.8.8.8

echo
echo "[5] PING GOOGLE"
ping -c 3 google.com

echo "=== SELESAI ==="