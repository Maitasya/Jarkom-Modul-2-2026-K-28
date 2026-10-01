#!/bin/sh

CONF="/etc/bind/named.conf"
PRAB="192.225.5.2"

cat >> "$CONF" <<EOT2

zone "3.225.192.in-addr.arpa" IN {
    type slave;
    masters { $PRAB; };
    file "/var/bind/slave/3.225.192.in-addr.arpa";
};

zone "4.225.192.in-addr.arpa" IN {
    type slave;
    masters { $PRAB; };
    file "/var/bind/slave/4.225.192.in-addr.arpa";
};

zone "5.225.192.in-addr.arpa" IN {
    type slave;
    masters { $PRAB; };
    file "/var/bind/slave/5.225.192.in-addr.arpa";
};
EOT2

mkdir -p /var/bind/slave /var/run/named
chown named:named /var/bind/slave /var/run/named

named-checkconf "$CONF" || exit 1

pkill named 2>/dev/null
sleep 1
named -u named
sleep 5

for z in k28.com 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
do
    P=$(dig @192.225.5.2 "$z" SOA +short | awk '{print $3}')
    T=$(dig @192.225.5.3 "$z" SOA +short | awk '{print $3}')
    echo "$z: PRAB=$P TEDD=$T"
done
EOT