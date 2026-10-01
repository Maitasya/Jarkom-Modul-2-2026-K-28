#!/bin/sh

CONF="/etc/bind/named.conf"

cat >> "$CONF" <<'EOT2'

zone "3.225.192.in-addr.arpa" IN {
    type master;
    file "/var/bind/3.225.192.in-addr.arpa";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};

zone "4.225.192.in-addr.arpa" IN {
    type master;
    file "/var/bind/4.225.192.in-addr.arpa";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};

zone "5.225.192.in-addr.arpa" IN {
    type master;
    file "/var/bind/5.225.192.in-addr.arpa";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};
EOT2

named-checkconf "$CONF" || exit 1
named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa || exit 1
named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa || exit 1
named-checkzone 5.225.192.in-addr.arpa /var/bind/5.225.192.in-addr.arpa || exit 1

pkill named 2>/dev/null
sleep 1
named -u named
EOT