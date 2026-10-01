#!/bin/sh

echo "=== SOAL 3 ROOTKIT ==="

echo "[1] INTERFACE"
ip -br addr

echo
echo "[2] ROUTING"
ip route

echo
echo "[3] CEK GATEWAY WAN"
ping -c 3 192.168.122.1

echo
echo "[4] CEK JARINGAN INTERNAL"
ping -c 3 192.225.1.2
ping -c 3 192.225.5.2

echo "=== SELESAI ==="
