#!/bin/bash
IP="192.225.5.4"
GW="192.225.5.1"

ip addr flush dev eth0
ip addr add $IP/24 dev eth0
ip route replace default via $GW

cat > /etc/network/interfaces <<EOF2
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IP
netmask 255.255.255.0
gateway $GW
EOF2

ip -br addr
ip route
 
chmod +x /root/soal1.sh
/root/soal1.sh