#!/bin/bash

ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up
ip link set eth5 up

ip addr replace 192.225.5.1/24 dev eth1
ip addr replace 192.225.4.1/24 dev eth2
ip addr replace 192.225.3.1/24 dev eth3
ip addr replace 192.225.1.1/24 dev eth4
ip addr replace 192.225.2.1/24 dev eth5

echo "=== IP ADDRESS ==="
ip -br addr

echo "=== ROUTING ==="
ip route
