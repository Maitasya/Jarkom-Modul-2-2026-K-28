# Jarkom-Modul-2-2026-K-28

## Kelompok K-28

|            Nama           |     NRP    |
| :-----------------------: | :--------: |
|   Maitasya Rohmatul Ula   | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

---
# List SOAL

- [Soal 1 — Konfigurasi IP Address dan Default Gateway](#soal-1--konfigurasi-ip-address-dan-default-gateway)
- [Soal 2 — Konfigurasi NAT dan Akses Internet](#soal-2--konfigurasi-nat-dan-akses-internet)
- [Soal 3 — Routing Internal dan Resolver](#soal-3--routing-internal-dan-resolver)
- [Soal 4 — DNS Master-Slave dan Resolver](#soal-4-dns-master-slave-dan-resolver-k28)
- [Soal 5 — A Record Semua Entitas](#soal-5-a-record-semua-entitas)
- [Soal 6 — Verifikasi Zone Transfer PRAB dan TEDD](#soal-6-verifikasi-zone-transfer-prab-dan-tedd)
- [Soal 7 — Web Server Statis dan Dinamis pada DNS](#soal-7-web-server-statis-dan-dinamis-pada-dns)
- [Soal 8 — Reverse Zone dan PTR](#soal-8-reverse-zone-dan-ptr-master-prab-slave-tedd)
- [Soal 9 — Web Statis Apache dan AutoIndex](#soal-9--web-statis-apache-dan-autoindex)
- [Soal 10 — Web Dinamis Nginx dan PHP](#soal-10)
- [Soal 11 — Reverse Proxy & Load Balancing](#soal-11--reverse-proxy--load-balancing)
- [Soal 12 — Basic Authentication pada `/admin`](#soal-12--basic-authentication-pada-admin)
- [Soal 13 — Redirect Penny dan Abbey](#soal-13)
- [Soal 14 — Access Log dan X-Real-IP](#soal-14)
- [Soal 15 — Reverse Proxy Path Khusus](#soal-15--reverse-proxy-path-khusus)
- [Soal 16 — Stress Test ApacheBench](#soal-16--stress-test-apachebench)
- [Soal 17 — TXT Record DNS](#soal-17--txt-record-dns)
- [Soal 18 — Perubahan A Record, TTL, dan Sinkronisasi DNS](#soal-18--perubahan-a-record-ttl-dan-sinkronisasi-dns)
- [Soal 19 — CNAME `outbound.k28.com`](#soal-19--cname-outboundk28com-ke-httpbadsslcom)
- [Soal 20](#soal-20)

---
## Soal 1 — Konfigurasi IP Address dan Default Gateway

### Tujuan
Mengatur IP address dan default gateway seluruh node The Mesh dengan prefix `192.225.x.x`. rootkit menjadi router pusat yang menghubungkan lima switch.

### Topologi
Sesuai gambar topologi soal, rootkit tersambung ke lima switch:

| Interface rootkit | Switch | Node | Subnet |
|---|---|---|---|
| eth4 | Switch6 | alpha, beta, gamma | 192.225.1.0/24 |
| eth5 | Switch7 | delta, epsilon | 192.225.2.0/24 |
| eth3 | Switch5 | penny | 192.225.3.0/24 |
| eth2 | Switch4 | abbey | 192.225.4.0/24 |
| eth1 | Switch1 (Switch2 dan Switch3) | prab, tedd, obladi, desmond, oblada, molly | 192.225.5.0/24 |

<! topologi GNS3 >
<img width="959" height="415" alt="Screenshot 2026-09-28 204904" src="https://github.com/user-attachments/assets/737fa1bd-ff35-4f0c-adb9-66d82673ad52" />


### Tabel Konfigurasi IP

| No | Simpul | Interface | IP Address | Gateway |
|----|--------|-----------|------------|---------|
| 1 | rootkit | eth1 | 192.225.5.1/24 | - |
| 2 | rootkit | eth2 | 192.225.4.1/24 | - |
| 3 | rootkit | eth3 | 192.225.3.1/24 | - |
| 4 | rootkit | eth4 | 192.225.1.1/24 | - |
| 5 | rootkit | eth5 | 192.225.2.1/24 | - |
| 6 | alpha | eth0 | 192.225.1.2/24 | 192.225.1.1 |
| 7 | beta | eth0 | 192.225.1.3/24 | 192.225.1.1 |
| 8 | gamma | eth0 | 192.225.1.4/24 | 192.225.1.1 |
| 9 | delta | eth0 | 192.225.2.2/24 | 192.225.2.1 |
| 10 | epsilon | eth0 | 192.225.2.3/24 | 192.225.2.1 |
| 11 | abbey | eth0 | 192.225.4.2/24 | 192.225.4.1 |
| 12 | penny | eth0 | 192.225.3.3/24 | 192.225.3.1 |
| 13 | obladi | eth0 | 192.225.5.4/24 | 192.225.5.1 |
| 14 | desmond | eth0 | 192.225.5.5/24 | 192.225.5.1 |
| 15 | oblada | eth0 | 192.225.5.6/24 | 192.225.5.1 |
| 16 | molly | eth0 | 192.225.5.7/24 | 192.225.5.1 |
| 17 | prab | eth0 | 192.225.5.2/24 | 192.225.5.1 |
| 18 | tedd | eth0 | 192.225.5.3/24 | 192.225.5.1 |

Node yang IP-nya ikut topologi (abbey di Switch4, repository di Switch3 satu segmen dengan prab dan tedd) diatur mengikuti wiring, karena IP harus cocok dengan switch tempat node tersambung.

### Langkah Pengerjaan (Step by Step)

**1. Konfigurasi IP pada rootkit**

Pada **rootkit**, atur IP setiap interface sesuai subnet:

```sh
ip addr replace 192.225.5.1/24 dev eth1
ip addr replace 192.225.4.1/24 dev eth2
ip addr replace 192.225.3.1/24 dev eth3
ip addr replace 192.225.1.1/24 dev eth4
ip addr replace 192.225.2.1/24 dev eth5
```

**2. Konfigurasi IP dan gateway pada node**

Contoh pada **obladi**:

```sh
ip addr replace 192.225.5.4/24 dev eth0
ip route replace default via 192.225.5.1
```

**3. Verifikasi**

```sh
ip -br addr
ip route
ping -c 3 192.225.5.1
ping -c 3 8.8.8.8
```

<!ip -br addr, ip route, dan ping berhasil (mis. obladi) -->

<img width="569" height="430" alt="image" src="https://github.com/user-attachments/assets/ff86dc43-d58c-40b7-b29d-97d4c83d10e8" />

Perintah tersebut diulangi pada node lain dengan IP dan gateway sesuai tabel.

**4. Uji wiring dengan tcpdump**

Pada **rootkit**:

```sh
tcpdump -ni any 'arp or icmp'
```

Kemudian lakukan ping dari node ke gateway untuk memastikan paket masuk melalui interface rootkit yang sesuai.

### Versi Otomatis (Script)

Script `soal1_rootkit.sh` dibuat pada setiap node. Ubah nilai `IP` dan `GW` sesuai tabel.

Contoh untuk **obladi**:

```sh
#!/bin/sh

IP="192.225.5.4"
GW="192.225.5.1"

ip addr replace "$IP/24" dev eth0
ip route replace default via "$GW"

cat > /etc/network/interfaces <<EOT
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IP
netmask 255.255.255.0
gateway $GW
EOT

ip -br addr
ip route
EOF
```
jalankan :
```
chmod +x /root/soal1_rootkit.sh
/root/soal1_rootkit.sh
```

Nilai `IP` dan `GW` untuk node lainnya:

| Node    | IP          | GW          |
| ------- | ----------- | ----------- |
| alpha   | 192.225.1.2 | 192.225.1.1 |
| beta    | 192.225.1.3 | 192.225.1.1 |
| gamma   | 192.225.1.4 | 192.225.1.1 |
| delta   | 192.225.2.2 | 192.225.2.1 |
| epsilon | 192.225.2.3 | 192.225.2.1 |
| abbey   | 192.225.4.2 | 192.225.4.1 |
| penny   | 192.225.3.3 | 192.225.3.1 |
| prab    | 192.225.5.2 | 192.225.5.1 |
| tedd    | 192.225.5.3 | 192.225.5.1 |
| obladi  | 192.225.5.4 | 192.225.5.1 |
| desmond | 192.225.5.5 | 192.225.5.1 |
| oblada  | 192.225.5.6 | 192.225.5.1 |
| molly   | 192.225.5.7 | 192.225.5.1 |

Script verifikasi `cek_node*.sh` pada README sebelumnya tetap dapat digunakan sebagai pengecekan tambahan.

---

# Soal 2 — Konfigurasi NAT dan Akses Internet

## Tujuan

Mengaktifkan *IP forwarding* dan konfigurasi NAT pada `rootkit` agar seluruh jaringan internal dapat meneruskan lalu lintas menuju internet melalui interface WAN `eth0`.

### Konfigurasi Rootkit

Pada node **`rootkit`**, konfigurasi IP forwarding dan NAT dilakukan dengan perintah berikut:

```sh
sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT

iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

Konfigurasi tersebut mengaktifkan *IP forwarding*, melakukan *MASQUERADE* pada interface WAN `eth0`, serta mengizinkan lalu lintas dari seluruh jaringan internal menuju internet.

## Langkah Pengerjaan (Step by Step)

**1. Pastikan interface WAN `eth0` aktif pada rootkit**

```sh
ip -br addr
```

Pastikan `eth0` memiliki alamat IP dan berstatus `UP`.

**2. Aktifkan IP forwarding**

```sh
sysctl -w net.ipv4.ip_forward=1
```

Kemudian periksa:

```sh
sysctl net.ipv4.ip_forward
```

Hasil yang diharapkan:

```text
net.ipv4.ip_forward = 1
```

**3. Aktifkan NAT dan forwarding**

```sh
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT

iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

**4. Uji akses internet dari node internal**

Contoh pada `alpha`:

```sh
ping -c 3 8.8.8.8
```

Kemudian:

```sh
ping -c 3 google.com
```
<img width="410" height="179" alt="image" src="https://github.com/user-attachments/assets/a74ae3e5-43d8-4cae-a905-97583a53a178" />

Jika `8.8.8.8` berhasil tetapi `google.com` gagal, periksa DNS:

```sh
cat /etc/resolv.conf
```

Jika diperlukan, tambahkan:

```text
nameserver 8.8.8.8
nameserver 1.1.1.1
```

Kemudian lakukan pengujian kembali:

```sh
ping -c 3 google.com
```

### Versi Otomatis (Script)

Agar konfigurasi NAT dan pengecekan dapat dilakukan dengan lebih cepat saat demo, dibuat script `soal2.sh` pada **rootkit**:

```sh
#!/bin/sh

echo "=== SOAL 2 - KONFIGURASI NAT ==="

echo "[1] Mengaktifkan IP forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "[2] Mengaktifkan NAT..."
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null ||
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "[3] Mengaktifkan forwarding jaringan internal..."
for IFACE in eth1 eth2 eth3 eth4 eth5
do
    iptables -C FORWARD -i "$IFACE" -o eth0 -j ACCEPT 2>/dev/null ||
    iptables -A FORWARD -i "$IFACE" -o eth0 -j ACCEPT
done

echo "[4] Mengizinkan koneksi balasan..."
iptables -C FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null ||
iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo
echo "=== VERIFIKASI ROOTKIT ==="
echo "[IP Forwarding]"
sysctl net.ipv4.ip_forward

echo
echo "[WAN]"
ip -br addr show eth0

echo
echo "[NAT]"
iptables -t nat -L POSTROUTING -n -v

echo
echo "[FORWARD]"
iptables -L FORWARD -n -v

echo
echo "=== SELESAI ==="
```

Jalankan pada **rootkit**:

```sh
chmod +x /root/soal2_rootkit.sh
/root/soal2_rootkit.sh
```

Setelah script selesai, uji dari salah satu node internal:

```sh
ping -c 3 8.8.8.8
ping -c 3 google.com
```
atau pakek scrip soal2_cek.sh

```#!/bin/sh

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
```
Jalankan pada **node lain**:

```sh
chmod +x /root/soal2_cek.sh
/root/soal2_cek.sh
```

Jika kedua pengujian berhasil, maka konfigurasi NAT, *IP forwarding*, dan akses internet pada jaringan internal telah berjalan.

---

# Soal 3 — Routing Internal dan Resolver

## Tujuan

Memastikan seluruh Entitas dapat saling berkomunikasi melalui `rootkit` sebagai router serta memastikan setiap host non-router memiliki resolver `192.168.122.1` untuk mendukung akses jaringan dan instalasi paket.

### Mengaktifkan Routing pada Rootkit

Pada console `rootkit`:

```sh
sysctl -w net.ipv4.ip_forward=1
sysctl net.ipv4.ip_forward
```

Hasil yang diharapkan:

```text
net.ipv4.ip_forward = 1
```

### Menambahkan Resolver pada Host Non-Router

Pada setiap host non-router, cek terlebih dahulu:

```sh
cat /etc/resolv.conf
```

Jika `192.168.122.1` belum tersedia, tambahkan:

```sh
echo "nameserver 192.168.122.1" >> /etc/resolv.conf
```

Jika resolver `192.168.122.1` sudah tersedia, tidak perlu menambahkan resolver lain seperti Google.

### Pengujian Routing Internal

Dari salah satu host, misalnya `alpha`:

```sh
ping -c 3 192.225.1.1
ping -c 3 192.225.5.2
```

Perintah pertama menguji koneksi ke `rootkit`, sedangkan perintah kedua menguji komunikasi lintas jaringan melalui `rootkit`.

### Pengujian DNS

```sh
ping -c 3 google.com
```

Jika berhasil, berarti resolver dan koneksi jaringan sudah dapat digunakan.

### Versi Otomatis (Script)

Script `soal3.sh` dibuat pada setiap **host non-router**. Isi script sama untuk semua host:

```sh
#!/bin/sh

echo "=== SOAL 3 $(hostname) ==="

echo "[1] RESOLVER"

if grep -q "192.168.122.1" /etc/resolv.conf; then
    echo "Resolver 192.168.122.1 sudah tersedia"
else
    echo "nameserver 192.168.122.1" >> /etc/resolv.conf
    echo "Resolver 192.168.122.1 ditambahkan"
fi

cat /etc/resolv.conf

echo
echo "[2] DEFAULT GATEWAY"
ip route | grep default

echo
echo "[3] CEK GATEWAY"
GW=$(ip route | awk '/default/ {print $3; exit}')

if [ -n "$GW" ]; then
    ping -c 3 "$GW"
else
    echo "Default gateway tidak ditemukan"
fi

echo
echo "[4] CEK LINTAS JARINGAN"
ping -c 3 192.225.5.2

echo
echo "[5] CEK DNS"
ping -c 3 google.com

echo "=== SELESAI ==="
```

Script dibuat dan dijalankan dengan:

```sh
cat > /root/soal3.sh <<'EOF'
# isi script soal3.sh
EOF

chmod +x /root/soal3.sh
/root/soal3.sh
```

Script tersebut dapat digunakan dengan isi yang sama pada `alpha`, `beta`, `gamma`, `delta`, `epsilon`, `abbey`, `penny`, `prab`, `tedd`, `obladi`, `desmond`, `oblada`, dan `molly`.

hasil:
<img width="959" height="481" alt="image" src="https://github.com/user-attachments/assets/f5f3c478-fe55-4401-8068-b8831ce6df52" />

---
## Soal 4: DNS Master-Slave dan Resolver (K28)

## Tujuan:
| Node | Peran | IP |
|------|-------|----|
| prab | DNS master (ns1) | 192.225.5.2 |
| tedd | DNS slave (ns2) | 192.225.5.3 |
| penny | Gerbang aplikasi dinamis (A record apex) | 192.225.3.3 |

- prab menjadi master authoritative untuk zona `k28.com` (SOA, NS, A record, notify, allow-transfer, forwarders `192.168.122.1`).
- tedd menarik zona dari prab dan menjawab secara authoritative.
- Semua node non-router memakai urutan resolver: prab, tedd, `192.168.122.1`.

### Langkah Pengerjaan

**1. Persiapan (console prab dan tedd)**

```sh
cat /etc/resolv.conf
ping -c 2 google.com
ping -c 2 192.225.5.3   # dari prab
ping -c 2 192.225.5.2   # dari tedd
apk update
apk add bind bind-tools
```

**2. Konfigurasi di console prab (master)**

```sh
cat > /etc/bind/named.conf <<'EOF'
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";
    listen-on { 127.0.0.1; 192.225.5.2; };
    listen-on-v6 { none; };
    forwarders { 192.168.122.1; };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    dnssec-validation no;
};

zone "k28.com" IN {
    type master;
    file "/var/bind/k28.com";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};
EOF
```

File zona. Serial awal sengaja kecil (`1790000001`), lebih kecil dari `date +%s`, supaya perubahan berikutnya yang memakai timestamp selalu dianggap lebih baru oleh tedd:

```sh
cat > /var/bind/k28.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            1790000001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.k28.com.
@       IN  NS  tedd.k28.com.
prab    IN  A   192.225.5.2
tedd    IN  A   192.225.5.3
@       IN  A   192.225.3.3
EOF
```

```sh
named-checkconf /etc/bind/named.conf
named-checkzone k28.com /var/bind/k28.com
mkdir -p /var/run/named
chown named:named /var/run/named
pkill named
sleep 1
named -u named
```

<img width="959" height="56" alt="image" src="https://github.com/user-attachments/assets/d9277603-0286-492f-94f8-0e23cf01e76c" />

**3. Verifikasi prab**

```sh
dig @192.225.5.2 k28.com
dig @192.225.5.2 prab.k28.com +short
dig @192.225.5.2 tedd.k28.com +short
dig @192.225.5.2 k28.com NS +short
dig @192.225.5.2 google.com +short
```

Hasil yang benar:
- `k28.com` punya flags `qr aa` dan menjawab `192.225.3.3` (penny).
- `prab.k28.com` menjawab `192.225.5.2`, `tedd.k28.com` menjawab `192.225.5.3`.
- NS menjawab `prab.k28.com.` dan `tedd.k28.com.`.
- `google.com` menjawab (forwarder berjalan).

<!-- SS: dig k28.com (flags aa, jawaban 192.225.3.3) dan dig lainnya -->
<img width="959" height="368" alt="image" src="https://github.com/user-attachments/assets/c73e33f1-2bfe-48bb-89af-1d57a4da458c" />

**4. Konfigurasi tedd (slave)**

```sh
mkdir -p /var/bind/slave
chown named:named /var/bind/slave
chmod 775 /var/bind/slave
rm -f /var/bind/slave/k28.com

cat > /etc/bind/named.conf <<'EOF'
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";
    listen-on { 127.0.0.1; 192.225.5.3; };
    listen-on-v6 { none; };
    forwarders { 192.168.122.1; };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    dnssec-validation no;
};

zone "k28.com" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/k28.com";
};
EOF

named-checkconf /etc/bind/named.conf
mkdir -p /var/run/named
chown named:named /var/run/named
pkill named
sleep 1
named -u named
sleep 5
```

**5. Verifikasi tedd**

```sh
ls -l /var/bind/slave/
```
```
dig @192.225.5.3 k28.com
dig @192.225.5.2 k28.com SOA +short
dig @192.225.5.3 k28.com SOA +short
```

Hasil yang benar: file `k28.com` ada di `/var/bind/slave/`, flags `qr aa`, jawaban `192.225.3.3`, dan serial prab dan tedd sama (`1790000001`).

<!-- SS: ls slave, dig @tedd k28.com, dan dua SOA -->
<img width="959" height="266" alt="image" src="https://github.com/user-attachments/assets/66ce95c4-ce62-4f90-b7ba-0eb89b61c871" />

**6. Ubah resolver di semua node non-router**

Node: alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly.

```sh
cat > /root/resolver_soal4.sh <<'EOF'
#!/bin/sh
cat > /etc/resolv.conf <<'EOT'
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
EOT
cat /etc/resolv.conf
EOF
chmod +x /root/resolver_soal4.sh
/root/resolver_soal4.sh
```

**7. Verifikasi resolver (tiap node)**

```sh
cat /etc/resolv.conf
dig k28.com +short
dig prab.k28.com +short
dig google.com +short
```

Hasil yang benar: urutan resolver `192.225.5.2`, `192.225.5.3`, `192.168.122.1`. `k28.com` menjawab `192.225.3.3`, `prab.k28.com` menjawab `192.225.5.2`, dan `google.com` tetap menjawab.

<img width="959" height="450" alt="image" src="https://github.com/user-attachments/assets/3f0a04d4-2e0c-4af9-be06-e2cd79d45084" />


### Versi Otomatis (Script)

| Script | Node | Fungsi |
|--------|------|--------|
| soal4_prab.sh | prab | Install bind, konfigurasi master, buat zona, jalankan named |
| soal4_tedd.sh | tedd | Install bind, konfigurasi slave, jalankan named |
| resolver_soal4.sh | 13 node non-router | Ubah urutan resolver |

**`soal4_prab.sh` (prab)**

```sh
cat > /root/soal4_prab.sh <<'EOT'
#!/bin/sh
echo "=== Konfigurasi DNS PRAB - K28 ==="

DOMAIN="k28.com"
IP_PRAB="192.225.5.2"
IP_TEDD="192.225.5.3"
IP_PENNY="192.225.3.3"

apk update
apk add bind bind-tools

cat > /etc/bind/named.conf <<EOF
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";
    listen-on { 127.0.0.1; $IP_PRAB; };
    listen-on-v6 { none; };
    forwarders { 192.168.122.1; };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    dnssec-validation no;
};

zone "$DOMAIN" IN {
    type master;
    file "/var/bind/$DOMAIN";
    notify yes;
    also-notify { $IP_TEDD; };
    allow-transfer { $IP_TEDD; };
};
EOF

cat > /var/bind/$DOMAIN <<EOF
\$TTL 604800
@   IN  SOA prab.$DOMAIN. root.$DOMAIN. (
            $(date +%s)  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.$DOMAIN.
@       IN  NS  tedd.$DOMAIN.
prab    IN  A   $IP_PRAB
tedd    IN  A   $IP_TEDD
@       IN  A   $IP_PENNY
EOF

mkdir -p /var/run/named
chown named:named /var/run/named

echo "=== Cek konfigurasi ==="
named-checkconf /etc/bind/named.conf
named-checkzone $DOMAIN /var/bind/$DOMAIN

echo "=== Jalankan named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2
echo "=== Selesai ==="
EOT
```
jalankan perintah:

 ```
chmod +x /root/soal4_prab.sh
./soal4_prab.sh
```

**`soal4_tedd.sh` (tedd)**

```sh
cat > /root/soal4_tedd.sh <<'EOT'
#!/bin/sh
echo "=== Konfigurasi DNS TEDD - K28 ==="

DOMAIN="k28.com"
IP_PRAB="192.225.5.2"
IP_TEDD="192.225.5.3"

apk update
apk add bind bind-tools

pkill named 2>/dev/null
mkdir -p /var/bind/slave
chown named:named /var/bind/slave
chmod 775 /var/bind/slave
rm -f /var/bind/slave/$DOMAIN

cat > /etc/bind/named.conf <<EOF
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";
    listen-on { 127.0.0.1; $IP_TEDD; };
    listen-on-v6 { none; };
    forwarders { 192.168.122.1; };
    forward only;
    recursion yes;
    allow-recursion { any; };
    allow-query { any; };
    dnssec-validation no;
};

zone "$DOMAIN" IN {
    type slave;
    masters { $IP_PRAB; };
    file "/var/bind/slave/$DOMAIN";
};
EOF

mkdir -p /var/run/named
chown named:named /var/run/named

echo "=== Cek konfigurasi ==="
named-checkconf /etc/bind/named.conf

echo "=== Jalankan named ==="
sleep 1
named -u named

echo "=== Tunggu zone transfer dari PRAB ==="
sleep 5

echo "=== Cek file slave ==="
ls -l /var/bind/slave/

echo "=== Selesai ==="
EOT
chmod +x /root/soal4_tedd.sh
```
jalankan perintah:

 ```
chmod +x /root/soal4_tedd.sh
./soal4_tedd.sh
```
Urutan: `soal4_prab.sh` di prab, lalu `soal4_tedd.sh` di tedd (tunggu 5 sampai 10 detik), lalu `resolver_soal4.sh` di semua node non-router.

ikuti urutan menjalakannya :

### 1. PRAB

 jalankan:

```sh
chmod +x /root/soal4_prab.sh
/root/soal4_prab.sh
```

Setelah selesai, cek:

```sh
dig @192.225.5.2 k28.com +short
```

Harus keluar:

```text
192.225.3.3
```

### 2. TEDD

```sh
chmod +x /root/soal4_tedd.sh
/root/soal4_tedd.sh
```

Tunggu 5–10 detik, lalu:

```sh
ls /var/bind/slave/
```

Harus ada:

```text
dig k28.com +short
```

Tes:

```sh
dig @192.225.5.3 k28.com +short
```

Harus:

```text
192.225.3.3
```

### 3. Resolver semua node

Script `resolver_soal4.sh` harus sudah ada di setiap node.

Di **alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly**, jalankan:

```sh
chmod +x /root/resolver_soal4.sh
/root/resolver_soal4.sh
```

### 4. Cek akhir

Di salah satu node non-router:

```sh
cat /etc/resolv.conf
```

Harus:

```text
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
```

Lalu:

```sh
dig k28.com +short
dig prab.k28.com +short
dig google.com +short
```

Target:

```text
192.225.3.3
192.225.5.2
IP Google
```
---
## Soal 5: A Record Semua Entitas

### Tujuan

Menamai seluruh Entitas (*hostname*) sesuai glosarium dan memastikan setiap host mengenali nama tersebut secara *system-wide*. Selanjutnya, menambahkan A record semua entitas ke zona `k28.com` di `prab`, lalu memastikan `tedd` menarik zona terbaru.

### Tabel Record

| Hostname | IP          |
| -------- | ----------- |
| rootkit  | 192.225.5.1 |
| alpha    | 192.225.1.2 |
| beta     | 192.225.1.3 |
| gamma    | 192.225.1.4 |
| delta    | 192.225.2.2 |
| epsilon  | 192.225.2.3 |
| abbey    | 192.225.4.2 |
| penny    | 192.225.3.3 |
| prab     | 192.225.5.2 |
| tedd     | 192.225.5.3 |
| obladi   | 192.225.5.4 |
| desmond  | 192.225.5.5 |
| oblada   | 192.225.5.6 |
| molly    | 192.225.5.7 |

`prab`, `tedd`, dan apex `k28.com` sudah ada dari Soal 4 sehingga tidak dibuat ulang pada bagian penambahan record.

### Langkah Pengerjaan (Step by Step)

**1. Konfigurasi hostname setiap Entitas**

Pada masing-masing node, hostname diatur sesuai nama Entitas.

Contoh pada `alpha`:

```sh
hostname alpha
echo "alpha" > /etc/hostname
```

Contoh pada `beta`:

```sh
hostname beta
echo "beta" > /etc/hostname
```

Konfigurasi dilakukan sesuai nama masing-masing:

| Node    | Hostname  |
| ------- | --------- |
| rootkit | `rootkit` |
| alpha   | `alpha`   |
| beta    | `beta`    |
| gamma   | `gamma`   |
| delta   | `delta`   |
| epsilon | `epsilon` |
| prab    | `prab`    |
| tedd    | `tedd`    |
| abbey   | `abbey`   |
| penny   | `penny`   |
| obladi  | `obladi`  |
| desmond | `desmond` |
| oblada  | `oblada`  |
| molly   | `molly`   |

Verifikasi pada setiap node:

```sh
hostname
cat /etc/hostname
```

**2. Menambahkan pemetaan hostname secara system-wide**

Pada setiap node, tambahkan pemetaan seluruh Entitas ke `/etc/hosts`:

```sh
cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
192.225.5.1 rootkit rootkit.k28.com
192.225.1.2 alpha alpha.k28.com
192.225.1.3 beta beta.k28.com
192.225.1.4 gamma gamma.k28.com
192.225.2.2 delta delta.k28.com
192.225.2.3 epsilon epsilon.k28.com
192.225.5.2 prab prab.k28.com
192.225.5.3 tedd tedd.k28.com
192.225.4.2 abbey abbey.k28.com
192.225.3.3 penny penny.k28.com
192.225.5.4 obladi obladi.k28.com
192.225.5.5 desmond desmond.k28.com
192.225.5.6 oblada oblada.k28.com
192.225.5.7 molly molly.k28.com
EOF
```

Verifikasi:

```sh
getent hosts alpha
getent hosts prab
getent hosts molly
```

Hasil menunjukkan IP yang sesuai dengan hostname.

**3. Cek zona sebelum diubah (prab)**

Pada console `prab`:

```sh
cat /var/bind/k28.com
```

**4. Tambahkan record (prab)**

```sh
cat >> /var/bind/k28.com <<'EOF'
rootkit IN  A   192.225.5.1
alpha   IN  A   192.225.1.2
beta    IN  A   192.225.1.3
gamma   IN  A   192.225.1.4
delta   IN  A   192.225.2.2
epsilon IN  A   192.225.2.3
abbey   IN  A   192.225.4.2
penny   IN  A   192.225.3.3
obladi  IN  A   192.225.5.4
desmond IN  A   192.225.5.5
oblada  IN  A   192.225.5.6
molly   IN  A   192.225.5.7
EOF
```

`prab` dan `tedd` tidak ditambahkan kembali karena record tersebut sudah dibuat pada Soal 4.

**5. Naikkan serial supaya tedd menarik zona baru (prab)**

```sh
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" /var/bind/k28.com
```

**6. Cek zona lalu muat ulang named (prab)**

```sh
named-checkzone k28.com /var/bind/k28.com
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2
```

Jika `named-checkzone` menghasilkan `OK`, zona dapat dimuat kembali.

**7. Tes semua nama (prab)**

```sh
for h in rootkit alpha beta gamma delta epsilon prab tedd abbey penny obladi desmond oblada molly; do
    echo -n "$h: "
    dig @192.225.5.2 $h.k28.com +short
done
```

Hasil menunjukkan setiap hostname memiliki IP sesuai tabel.
<img width="959" height="247" alt="image" src="https://github.com/user-attachments/assets/f84da551-14fc-4ac9-94b9-7c6027a8b28e" />

Apex juga diuji:

```sh
dig @192.225.5.2 k28.com +short
```

Hasil:

```text
192.225.3.3
```

**8. Cek sinkronisasi di tedd**

Pada console `tedd`:

```sh
dig @192.225.5.3 k28.com SOA +short
dig @192.225.5.3 abbey.k28.com +short
dig @192.225.5.3 molly.k28.com +short
```

Hasil yang benar:
<img width="959" height="89" alt="image" src="https://github.com/user-attachments/assets/67cd0c76-5a2e-4c1e-b9aa-1b45e4e9749b" />

```text
abbey → 192.225.4.2
molly → 192.225.5.7
```

Serial pada `tedd` harus sama dengan serial pada `prab`.

Jika tedd masih menjawab data lama, lakukan:

```sh
pkill named 2>/dev/null
rm -f /var/bind/slave/k28.com
named -u named
sleep 5
```

Kemudian ulangi pengujian DNS.

### Versi Otomatis (Script)

| Script              | Node    | Fungsi                                                          |
| ------------------- | ------- | --------------------------------------------------------------- |
| `hostname_soal5.sh` | 14 node | Mengatur hostname dan `/etc/hosts`                              |
| `soal5_prab.sh`     | prab    | Menambahkan A record, menaikkan serial, dan memuat ulang master |
| `soal5_tedd.sh`     | tedd    | Memastikan slave mengambil zona terbaru                         |

**`hostname_soal5.sh`**

Script ini dibuat dengan nama hostname yang berbeda sesuai node. Bagian `HOSTNAME` disesuaikan dengan node tempat script dijalankan.

```sh
cat > /root/hostname_soal5.sh <<'EOT'
#!/bin/sh

HOSTNAME_NODE="$1"

if [ -z "$HOSTNAME_NODE" ]; then
    echo "Gunakan: /root/hostname_soal5.sh <hostname>"
    exit 1
fi

echo "=== KONFIGURASI HOSTNAME ==="

hostname "$HOSTNAME_NODE"
echo "$HOSTNAME_NODE" > /etc/hostname

cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
192.225.5.1 rootkit rootkit.k28.com
192.225.1.2 alpha alpha.k28.com
192.225.1.3 beta beta.k28.com
192.225.1.4 gamma gamma.k28.com
192.225.2.2 delta delta.k28.com
192.225.2.3 epsilon epsilon.k28.com
192.225.5.2 prab prab.k28.com
192.225.5.3 tedd tedd.k28.com
192.225.4.2 abbey abbey.k28.com
192.225.3.3 penny penny.k28.com
192.225.5.4 obladi obladi.k28.com
192.225.5.5 desmond desmond.k28.com
192.225.5.6 oblada oblada.k28.com
192.225.5.7 molly molly.k28.com
EOF

echo "Hostname: $(hostname)"
echo
echo "=== /etc/hosts ==="
cat /etc/hosts
echo
echo "=== SELESAI ==="
EOT

chmod +x /root/hostname_soal5.sh
```

Contoh penggunaan pada `alpha`:

```sh
/root/hostname_soal5.sh alpha
```

Pada `beta`:

```sh
/root/hostname_soal5.sh beta
```

Dan seterusnya sesuai nama node.

---

**`soal5_prab.sh` (prab)**

```sh
cat > /root/soal5_prab.sh <<'EOT'
#!/bin/sh

echo "=== SOAL 5: A RECORD SEMUA ENTITAS ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

echo "[1] HAPUS RECORD LAMA"

for h in rootkit alpha beta gamma delta epsilon abbey penny obladi desmond oblada molly; do
    sed -i "/^$h[[:space:]]/d" "$ZONA"
done

echo "[2] TAMBAHKAN A RECORD"

cat >> "$ZONA" <<'EOF'
rootkit IN  A   192.225.5.1
alpha   IN  A   192.225.1.2
beta    IN  A   192.225.1.3
gamma   IN  A   192.225.1.4
delta   IN  A   192.225.2.2
epsilon IN  A   192.225.2.3
abbey   IN  A   192.225.4.2
penny   IN  A   192.225.3.3
obladi  IN  A   192.225.5.4
desmond IN  A   192.225.5.5
oblada  IN  A   192.225.5.6
molly   IN  A   192.225.5.7
EOF

echo "[3] NAIKKAN SERIAL"

sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" "$ZONA"

echo "[4] CEK ZONA"

named-checkzone k28.com "$ZONA" || exit 1

echo "[5] MUAT ULANG NAMED"

pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "[6] TES DNS"

for h in rootkit alpha beta gamma delta epsilon prab tedd abbey penny obladi desmond oblada molly; do
    echo -n "$h: "
    dig @192.225.5.2 "$h.k28.com" +short
done

echo -n "k28.com (apex): "
dig @192.225.5.2 k28.com +short

echo "=== SOAL 5 PRAB SELESAI ==="
EOT

chmod +x /root/soal5_prab.sh
```

Jalankan **di PRAB**:

```sh
/root/soal5_prab.sh
```

---

**`soal5_tedd.sh` (tedd)**

Tambahkan script ini supaya bagian TEDD juga bisa dilakukan otomatis setelah PRAB diperbarui:

```sh
cat > /root/soal5_tedd.sh <<'EOT'
#!/bin/sh

echo "=== SOAL 5: SINKRONISASI TEDD ==="

echo "[1] TUNGGU ZONE TRANSFER"
sleep 5

echo "[2] CEK FILE SLAVE"
ls -l /var/bind/slave/

echo "[3] CEK SOA TEDD"
dig @192.225.5.3 k28.com SOA +short

echo "[4] CEK A RECORD"

echo -n "abbey: "
dig @192.225.5.3 abbey.k28.com +short

echo -n "molly: "
dig @192.225.5.3 molly.k28.com +short

echo "=== SOAL 5 TEDD SELESAI ==="
EOT

chmod +x /root/soal5_tedd.sh
```

Jalankan **di TEDD setelah script PRAB selesai**:

```sh
/root/soal5_tedd.sh
```

### 1. Jalankan script

```sh
chmod +x /root/soal5_prab.sh
/root/soal5_prab.sh
```

Tunggu sampai muncul:

```text
=== Selesai ===
```

### 2. Setelah itu pindah ke TEDD

```text
tedd:~#
```

Cek sinkronisasi:

```sh
dig @192.225.5.3 k28.com SOA +short
dig @192.225.5.3 abbey.k28.com +short
dig @192.225.5.3 molly.k28.com +short
```

Target:

```text
abbey → 192.225.4.2
molly → 192.225.5.7
```
---
## Soal 6: Verifikasi Zone Transfer PRAB dan TEDD

### Tujuan

Memastikan proses zone transfer dari **PRAB sebagai DNS Master** ke **TEDD sebagai DNS Slave** berjalan dengan baik. TEDD harus menerima salinan zona terbaru dari PRAB. Nilai serial SOA pada PRAB dan TEDD harus sama.

### 1. Mengecek Serial SOA pada PRAB

Pada console **PRAB**, dilakukan pengecekan serial SOA menggunakan perintah:

```sh
dig @192.225.5.2 k28.com SOA +short
```

Hasil:

<img width="959" height="55" alt="image" src="https://github.com/user-attachments/assets/8448dfaa-e751-470f-9d76-c1855d54a43b" />

### 2. Mengecek Serial SOA pada TEDD

Selanjutnya dilakukan pengecekan pada **TEDD** menggunakan perintah:

```sh
dig @192.225.5.3 k28.com SOA +short
```

Hasil:

<img width="959" height="52" alt="image" src="https://github.com/user-attachments/assets/4dfc6aaa-08a2-4946-83b6-b917cb559b62" />

### 3. Mengecek Record Terbaru pada TEDD

Untuk memastikan TEDD telah menerima zona terbaru dari PRAB, dilakukan pengecekan beberapa record:

```sh
dig @192.225.5.3 abbey.k28.com +short
192.225.4.2

dig @192.225.5.3 molly.k28.com +short
192.225.5.7
```

Hasil tersebut menunjukkan bahwa record `abbey.k28.com` dan `molly.k28.com` sudah tersedia dan dapat dijawab oleh DNS TEDD.

<img width="959" height="77" alt="image" src="https://github.com/user-attachments/assets/902e662c-3287-470b-8234-50b6da842dce" />

### 4. Mengecek File Zona pada TEDD

Salinan zona yang diterima TEDD juga dapat dilihat pada directory slave:

```sh
ls -lh /var/bind/slave/k28.com
```

File `k28.com` terdapat pada directory tersebut, sehingga TEDD memiliki salinan zona dari PRAB.

<img width="959" height="61" alt="image" src="https://github.com/user-attachments/assets/d24f1487-6946-45a8-b43b-89d5510a3778" />

### Kesimpulan

Berdasarkan hasil pengujian, proses **zone transfer dari PRAB ke TEDD berhasil dilakukan**. Hal ini dibuktikan dengan nilai serial SOA pada PRAB dan TEDD yang sama, yaitu `1790844358`. Selain itu, record `abbey.k28.com` dan `molly.k28.com` juga dapat diakses melalui TEDD. Dengan demikian, TEDD telah menerima dan menyimpan salinan zona terbaru dari PRAB.

## Versi Otomatis (script)

### 1. Script PRAB

Pada **PRAB**, script `soal6_prab.sh` digunakan untuk membuat reverse zone sebagai master dan mengizinkan zone transfer ke TEDD. Script dibuat aman untuk dijalankan kembali dengan menghapus konfigurasi reverse zone lama terlebih dahulu sehingga tidak terjadi duplikasi konfigurasi.

```sh
'EOT'
#!/bin/sh

CONF="/etc/bind/named.conf"
BACKUP="/etc/bind/named.conf.soal6.bak"

echo "=== SOAL 6 - KONFIGURASI PRAB ==="

echo "[1] CEK FILE ZONE"
for ZONE in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
do
    if [ ! -f "/var/bind/$ZONE" ]; then
        echo "File zone /var/bind/$ZONE tidak ditemukan"
        exit 1
    fi
done

echo "[2] BACKUP KONFIGURASI"
cp "$CONF" "$BACKUP"

echo "[3] HAPUS KONFIGURASI REVERSE ZONE LAMA"
sed -i '/zone "3\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"
sed -i '/zone "4\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"
sed -i '/zone "5\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"

echo "[4] TAMBAHKAN REVERSE ZONE"
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

echo "[5] CEK KONFIGURASI"
if ! named-checkconf "$CONF"; then
    echo "named-checkconf ERROR"
    cp "$BACKUP" "$CONF"
    exit 1
fi

echo "[6] CEK ZONE"
named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa || exit 1
named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa || exit 1
named-checkzone 5.225.192.in-addr.arpa /var/bind/5.225.192.in-addr.arpa || exit 1

echo "[7] RESTART NAMED"
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "[8] CEK SERIAL REVERSE ZONE"
for ZONE in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
do
    SERIAL=$(dig @192.225.5.2 "$ZONE" SOA +short | awk '{print $3}')
    echo "$ZONE : PRAB=$SERIAL"
done

echo "=== SOAL 6 PRAB SELESAI ==="
EOT
```

### Cara menjalankan PRAB

```sh
chmod +x /root/soal6_prab.sh
 /root/soal6_prab.sh
```

### 2. Script TEDD

Pada **TEDD**, script `soal6_tedd.sh` digunakan untuk membuat reverse zone sebagai slave dan mengecek kesamaan serial dengan PRAB. Script juga menghindari penambahan konfigurasi zone yang sama secara berulang.

```sh
'EOT'
#!/bin/sh

CONF="/etc/bind/named.conf"
BACKUP="/etc/bind/named.conf.soal6.bak"
PRAB="192.225.5.2"
TEDD="192.225.5.3"

echo "=== SOAL 6 - KONFIGURASI TEDD ==="

echo "[1] PERSIAPAN DIRECTORY"
mkdir -p /var/bind/slave
mkdir -p /var/run/named
chown named:named /var/bind/slave
chown named:named /var/run/named

echo "[2] BACKUP KONFIGURASI"
cp "$CONF" "$BACKUP"

echo "[3] HAPUS KONFIGURASI REVERSE ZONE LAMA"
sed -i '/zone "3\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"
sed -i '/zone "4\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"
sed -i '/zone "5\.225\.192\.in-addr\.arpa" IN {/,/^};/d' "$CONF"

echo "[4] TAMBAHKAN REVERSE ZONE SLAVE"
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

echo "[5] CEK KONFIGURASI"
if ! named-checkconf "$CONF"; then
    echo "named-checkconf ERROR"
    cp "$BACKUP" "$CONF"
    exit 1
fi

echo "[6] RESTART NAMED"
pkill named 2>/dev/null
sleep 1
named -u named

echo "[7] MENUNGGU ZONE TRANSFER"
sleep 2

echo "[8] CEK SERIAL"

for i in 1 2 3 4 5
do
    SEMUA_SAMA=1

    echo "Percobaan $i"

    for ZONE in k28.com 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
    do
        P=$(dig @$PRAB "$ZONE" SOA +short | awk '{print $3}')
        T=$(dig @$TEDD "$ZONE" SOA +short | awk '{print $3}')

        echo "$ZONE : PRAB=$P TEDD=$T"

        if [ -z "$P" ] || [ -z "$T" ] || [ "$P" != "$T" ]; then
            SEMUA_SAMA=0
        fi
    done

    if [ "$SEMUA_SAMA" -eq 1 ]; then
        echo
        echo "Semua serial SOA sama."
        echo "Zone transfer berhasil."
        break
    fi

    if [ "$i" -lt 5 ]; then
        echo "Zone transfer belum selesai, menunggu..."
        sleep 2
    fi
done

if [ "$SEMUA_SAMA" -ne 1 ]; then
    echo
    echo "Zone transfer belum berhasil."
    exit 1
fi

echo
echo "[9] CEK FILE SLAVE"
ls -lh /var/bind/slave/

echo
echo "[10] CEK RECORD HASIL TRANSFER"
dig @$TEDD abbey.k28.com +short
dig @$TEDD molly.k28.com +short

echo
echo "=== SOAL 6 TEDD SELESAI ==="
EOT
```

### Cara menjalankan TEDD

```sh
chmod +x /root/soal6_tedd.sh
root/soal6_tedd.sh
```
### Hasil yang dicari

```text
PRAB=SERIAL TEDD=SERIAL
```

Nilainya harus **sama**. Jika sama berarti **zone transfer berhasil**.

---
## Soal 7: Web Server Statis dan Dinamis pada DNS

### Tujuan

Menambahkan record pada zona `k28.com` untuk mengelompokkan node berdasarkan peran, lalu memverifikasi dari dua klien bahwa hasil resolve konsisten.

### Pembagian Peran

| Node    | IP          | Peran                   |
| ------- | ----------- | ----------------------- |
| abbey   | 192.225.4.2 | Gerbang utama           |
| penny   | 192.225.3.3 | Gerbang utama           |
| obladi  | 192.225.5.4 | Web statis (area vault) |
| desmond | 192.225.5.5 | Web statis (area vault) |
| oblada  | 192.225.5.6 | Web dinamis (area core) |
| molly   | 192.225.5.7 | Web dinamis (area core) |

### Record yang Ditambahkan

| Nama                              | Tipe  | Tujuan                                        |
| --------------------------------- | ----- | --------------------------------------------- |
| vault.k28.com                     | A     | 192.225.5.4 dan 192.225.5.5 (obladi, desmond) |
| core.k28.com                      | A     | 192.225.5.6 dan 192.225.5.7 (oblada, molly)   |
| [www.k28.com](http://www.k28.com) | CNAME | penny.k28.com.                                |
| static.k28.com                    | CNAME | abbey.k28.com.                                |

### Langkah Pengerjaan (Step by Step)

**1. Cek zona sebelum diubah (prab)**

```sh
cat /var/bind/k28.com
```

**2. Tambahkan record (prab)**

```sh
cat >> /var/bind/k28.com <<'EOF'
vault   IN  A      192.225.5.4
vault   IN  A      192.225.5.5
core    IN  A      192.225.5.6
core    IN  A      192.225.5.7
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF
```

**3. Naikkan serial (prab)**

```sh
CURRENT=$(awk '/; Serial/ {print $1; exit}' /var/bind/k28.com)
NEW=$(date +%s)

if [ "$NEW" -le "$CURRENT" ]; then
    NEW=$((CURRENT + 1))
fi

sed -i "s/[0-9]\{10\}\( *; Serial\)/$NEW\1/" /var/bind/k28.com
```

Perintah tersebut memastikan nilai serial baru lebih besar dari serial sebelumnya sehingga TEDD mengetahui bahwa terdapat perubahan pada zona.

**4. Cek zona lalu muat ulang named (prab)**

```sh
named-checkzone k28.com /var/bind/k28.com
```

Jika hasilnya `OK`, lanjutkan:

```sh
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2
```

**5. Cek isi zona setelah diubah (prab)**

```sh
grep -E "^(vault|core|www|static)" /var/bind/k28.com
```

Hasil yang dicari:

```text
vault   IN  A      192.225.5.4
vault   IN  A      192.225.5.5
core    IN  A      192.225.5.6
core    IN  A      192.225.5.7
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
```

**6. Tes resolve dari PRAB**

```sh
for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.2 $h.k28.com +short
done
```

Hasil yang diharapkan:

```text
vault:
192.225.5.4
192.225.5.5

core:
192.225.5.6
192.225.5.7

www:
penny.k28.com.
192.225.3.3

static:
abbey.k28.com.
192.225.4.2
```

**7. Verifikasi dari klien pertama (alpha)**

Jika `dig` belum tersedia:

```sh
apk add bind-tools
```

Kemudian:

```sh
for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.2 $h.k28.com +short
done
```

**8. Verifikasi dari klien kedua (delta)**

Perintah sama seperti langkah 7:

```sh
for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.2 $h.k28.com +short
done
```

Hasil dari **ALPHA dan DELTA harus menunjukkan tujuan yang sama**.

**9. Cek sinkronisasi ke TEDD**

```sh
dig @192.225.5.3 k28.com SOA +short

for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.3 $h.k28.com +short
done
```

Serial SOA pada TEDD harus sama dengan serial pada PRAB.

Jika TEDD masih menjawab data lama, dapat dilakukan sinkronisasi ulang:

```sh
pkill named 2>/dev/null
rm -f /var/bind/slave/k28.com
named -u named
sleep 5
```

Kemudian ulangi pengecekan pada langkah 9.

### Versi Otomatis (Script)

`soal7_prab.sh` (di prab):

```sh
cat > /root/soal7_prab.sh <<'EOT'
#!/bin/sh

echo "=== Soal 7: vault, core, CNAME ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

echo "[1] Hapus record soal 7 lama agar tidak duplikat"

for h in vault core www static
do
    sed -i "/^$h[[:space:]]/d" "$ZONA"
done

echo "[2] Tambahkan record"

cat >> "$ZONA" <<'EOF'
vault   IN  A      192.225.5.4
vault   IN  A      192.225.5.5
core    IN  A      192.225.5.6
core    IN  A      192.225.5.7
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF

echo "[3] Naikkan serial"

CURRENT=$(awk '/; Serial/ {print $1; exit}' "$ZONA")
NEW=$(date +%s)

if [ "$NEW" -le "$CURRENT" ]; then
    NEW=$((CURRENT + 1))
fi

sed -i "s/[0-9]\{10\}\( *; Serial\)/$NEW\1/" "$ZONA"

echo "[4] Cek zone"

named-checkzone k28.com "$ZONA" || exit 1

echo "[5] Restart named"

pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "[6] Cek record"

for h in vault core www static
do
    echo "$h:"
    dig @192.225.5.2 "$h.k28.com" +short
done

echo
echo "=== Isi zona ==="
grep -E "^(vault|core|www|static)" "$ZONA"

echo
echo "=== Serial SOA ==="
dig @192.225.5.2 k28.com SOA +short

echo
echo "=== Selesai ==="
EOT

chmod +x /root/soal7_prab.sh
/root/soal7_prab.sh
```

Script tersebut aman jika dijalankan ulang karena record `vault`, `core`, `www`, dan `static` dihapus terlebih dahulu sebelum dibuat kembali.

`soal7_cek.sh` (di alpha, delta, dan tedd):

```sh
cat > /root/soal7_cek.sh <<'EOT'
#!/bin/sh

echo "=== Cek soal 7 dari $(hostname) ==="

for s in 192.225.5.2 192.225.5.3
do
    echo
    echo "--- DNS Server $s ---"

    echo "Serial SOA:"
    dig @"$s" k28.com SOA +short

    for h in vault core www static
    do
        echo "$h:"
        dig @"$s" "$h.k28.com" +short
    done
done

echo
echo "=== Selesai ==="
EOT

chmod +x /root/soal7_cek.sh
/root/soal7_cek.sh
```

## Jalankan perintah berikut:

Menambahkan record `vault`, `core`, `www`, dan `static` pada PRAB lalu memastikan record dapat diakses dari client dan TEDD.

### 1. PRAB

```sh
chmod +x /root/soal7_prab.sh
 /root/soal7_prab.sh
```

Script menambahkan record baru ke zona `k28.com`, menaikkan serial, mengecek zona, kemudian menjalankan kembali `named`.

### 2. ALPHA

```sh
chmod +x /root/soal7_cek.sh
/root/soal7_cek.sh
```

Mengecek apakah record dari PRAB dapat di-resolve dari ALPHA.

### 3. DELTA

```sh
chmod +x /root/soal7_cek.sh
 /root/soal7_cek.sh
```

Mengecek resolusi record dari client kedua, yaitu DELTA.

### 4. TEDD

```sh
 chmod +x /root/soal7_cek.sh
 /root/soal7_cek.sh
```

Memastikan TEDD sebagai DNS slave sudah menerima record terbaru dari PRAB.

### Hasil yang diharapkan

```text
vault  → 192.225.5.4
vault  → 192.225.5.5

core   → 192.225.5.6
core   → 192.225.5.7

www    → penny.k28.com.
         192.225.3.3

static → abbey.k28.com.
         192.225.4.2
```
---

## Soal 8: Reverse Zone dan PTR (Master prab, Slave tedd)

### Tujuan

Mendeklarasikan reverse zone di prab (ns1) untuk segmen tempat abbey, penny, vault, dan core berada, menariknya sebagai slave di tedd (ns2), mengisi PTR, lalu memastikan query reverse dijawab authoritative.

### Pembagian Zona

| Segmen         | Zona reverse             | Isi                               |
| -------------- | ------------------------ | --------------------------------- |
| 192.225.3.0/24 | `3.225.192.in-addr.arpa` | penny (3.3)                       |
| 192.225.4.0/24 | `4.225.192.in-addr.arpa` | abbey (4.2)                       |
| 192.225.5.0/24 | `5.225.192.in-addr.arpa` | vault (5.4, 5.5), core (5.6, 5.7) |

### Record PTR

| IP          | PTR            |
| ----------- | -------------- |
| 192.225.3.3 | penny.k28.com. |
| 192.225.4.2 | abbey.k28.com. |
| 192.225.5.4 | vault.k28.com. |
| 192.225.5.5 | vault.k28.com. |
| 192.225.5.6 | core.k28.com.  |
| 192.225.5.7 | core.k28.com.  |

### Langkah Pengerjaan

#### Di prab (master)

**1. Deklarasikan tiga zona di named.conf**

Karena zona reverse sudah dibuat pada Soal 6, sebelum menambahkan konfigurasi dilakukan pengecekan terlebih dahulu.

```sh id="7j9v1b"
grep -n 'zone "3.225.192.in-addr.arpa"\|zone "4.225.192.in-addr.arpa"\|zone "5.225.192.in-addr.arpa"' /etc/bind/named.conf
```

Jika ketiga zona sudah muncul, **tidak perlu menambahkannya lagi**.

Jika belum ada, gunakan:

```sh id="jj4r9f"
cat >> /etc/bind/named.conf <<'EOF'

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
EOF
```

**2. Buat tiga file zona reverse**

```sh id="0f3gpf"
cat > /var/bind/3.225.192.in-addr.arpa <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            1790000001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
3   IN  PTR penny.k28.com.
EOF

cat > /var/bind/4.225.192.in-addr.arpa <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            1790000001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
2   IN  PTR abbey.k28.com.
EOF

cat > /var/bind/5.225.192.in-addr.arpa <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            1790000001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
4   IN  PTR vault.k28.com.
5   IN  PTR vault.k28.com.
6   IN  PTR core.k28.com.
7   IN  PTR core.k28.com.
EOF

cat /var/bind/3.225.192.in-addr.arpa
cat /var/bind/4.225.192.in-addr.arpa
cat /var/bind/5.225.192.in-addr.arpa
```

Ketiga file tersebut berisi PTR untuk `penny`, `abbey`, `vault`, dan `core`.

**3. Cek konfigurasi dan zona, lalu jalankan ulang named**

```sh id="b8cg7e"
named-checkconf /etc/bind/named.conf

named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa

named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa

named-checkzone 5.225.192.in-addr.arpa /var/bind/5.225.192.in-addr.arpa
```

Jika semuanya `OK`, jalankan:

```sh id="p6x1yo"
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2
```

**4. Tes reverse dari prab**

```sh id="8j7b1w"
dig @192.225.5.2 -x 192.225.3.3 +short
dig @192.225.5.2 -x 192.225.4.2 +short
dig @192.225.5.2 -x 192.225.5.4 +short
dig @192.225.5.2 -x 192.225.5.6 +short
```

Hasil yang diharapkan:
<img width="959" height="218" alt="image" src="https://github.com/user-attachments/assets/2dfe97be-7ed0-4de1-bd6a-95422ec28c22" />

```text
penny.k28.com.
abbey.k28.com.
vault.k28.com.
core.k28.com.
```

#### Di tedd (slave)

**5. Deklarasikan zona sebagai slave**

Karena reverse zone juga sudah dideklarasikan pada Soal 6, cek terlebih dahulu:

```sh id="e6e5ac"
grep -n 'zone "3.225.192.in-addr.arpa"\|zone "4.225.192.in-addr.arpa"\|zone "5.225.192.in-addr.arpa"' /etc/bind/named.conf
```

Jika ketiga zona sudah ada, **tidak perlu ditambahkan lagi**.

Jika belum ada, gunakan:

```sh id="yr6kzi"
cat >> /etc/bind/named.conf <<'EOF'

zone "3.225.192.in-addr.arpa" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/3.225.192.in-addr.arpa";
};

zone "4.225.192.in-addr.arpa" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/4.225.192.in-addr.arpa";
};

zone "5.225.192.in-addr.arpa" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/5.225.192.in-addr.arpa";
};
EOF
```

Kemudian:

```sh id="o4q1fj"
mkdir -p /var/bind/slave /var/run/named
chown named:named /var/bind/slave /var/run/named

named-checkconf /etc/bind/named.conf
```

Jika `named-checkconf` tidak menampilkan error:

```sh id="8a7r1k"
pkill named 2>/dev/null
sleep 1
named -u named
sleep 5

ls -lh /var/bind/slave/
```

Hasil yang dicari adalah tiga file reverse zone:
<img width="959" height="130" alt="image" src="https://github.com/user-attachments/assets/f0f841c8-621f-4cc4-ad26-e066ee4444c2" />

```text
3.225.192.in-addr.arpa
4.225.192.in-addr.arpa
5.225.192.in-addr.arpa
```

File `k28.com` juga tetap boleh ada karena merupakan hasil dari Soal 4.

#### Verifikasi authoritative

**6. Query ke tedd**

Untuk memastikan TEDD menjawab secara authoritative, digunakan flag `aa` pada hasil query:

```sh id="v6m20w"
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6
do
    echo "=== $ip ==="
    dig @192.225.5.3 -x $ip +noall +comments +answer
done
```

Pada bagian `flags`, hasil harus mengandung:

```text
aa
```

`aa` menunjukkan bahwa jawaban diberikan secara authoritative oleh DNS server tersebut.

**7. Query ke prab**

```sh id="0n1l3h"
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6
do
    echo "=== $ip ==="
    dig @192.225.5.2 -x $ip +noall +comments +answer
done
```

Hasil harus menunjukkan flag `aa` dan PTR yang sesuai.

**8. Cek sinkronisasi serial**

```sh id="l1y0zi"
for z in 3 4 5
do
    echo "=== $z.225.192.in-addr.arpa ==="
    echo "PRAB:"
    dig @192.225.5.2 $z.225.192.in-addr.arpa SOA +short

    echo "TEDD:"
    dig @192.225.5.3 $z.225.192.in-addr.arpa SOA +short
done
```

Serial pada masing-masing reverse zone di PRAB dan TEDD harus sama.

### Versi Otomatis (Script)

Script dibuat aman dijalankan ulang. Jika deklarasi zona sudah ada dari Soal 6, script tidak menambahkannya lagi.

**`soal8_prab.sh` (prab)**

```sh id="4m4p1v"
cat > /root/soal8_prab.sh <<'EOT'
#!/bin/sh

echo "=== Soal 8: reverse zone (prab) ==="

CONF="/etc/bind/named.conf"
SERIAL=$(date +%s)

echo "[1] Cek deklarasi reverse zone"

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
do
    if grep -q "zone \"$z\"" "$CONF"; then
        echo "$z sudah ada"
    else
        echo "$z belum ada, menambahkan..."

        cat >> "$CONF" <<EOF

zone "$z" IN {
    type master;
    file "/var/bind/$z";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};
EOF
    fi
done

echo "[2] Membuat file reverse zone"

cat > /var/bind/3.225.192.in-addr.arpa <<EOF
\$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            $SERIAL  ; Serial
            604800
            86400
            2419200
            604800 )
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
3   IN  PTR penny.k28.com.
EOF

cat > /var/bind/4.225.192.in-addr.arpa <<EOF
\$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            $SERIAL  ; Serial
            604800
            86400
            2419200
            604800 )
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
2   IN  PTR abbey.k28.com.
EOF

cat > /var/bind/5.225.192.in-addr.arpa <<EOF
\$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            $SERIAL  ; Serial
            604800
            86400
            2419200
            604800 )
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
4   IN  PTR vault.k28.com.
5   IN  PTR vault.k28.com.
6   IN  PTR core.k28.com.
7   IN  PTR core.k28.com.
EOF

echo "[3] Cek konfigurasi"

named-checkconf "$CONF" || exit 1

named-checkzone 3.225.192.in-addr.arpa \
    /var/bind/3.225.192.in-addr.arpa || exit 1

named-checkzone 4.225.192.in-addr.arpa \
    /var/bind/4.225.192.in-addr.arpa || exit 1

named-checkzone 5.225.192.in-addr.arpa \
    /var/bind/5.225.192.in-addr.arpa || exit 1

echo "[4] Restart named"

pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "[5] Tes reverse"

for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6
do
    echo -n "$ip: "
    dig @192.225.5.2 -x "$ip" +short
done

echo
echo "=== Serial PRAB ==="

for z in 3 4 5
do
    dig @192.225.5.2 "$z.225.192.in-addr.arpa" SOA +short
done

echo
echo "=== SOAL 8 PRAB SELESAI ==="
EOT

chmod +x /root/soal8_prab.sh
/root/soal8_prab.sh
```

**`soal8_tedd.sh` (tedd, jalankan setelah PRAB)**

```sh id="42p3l7"
cat > /root/soal8_tedd.sh <<'EOT'
#!/bin/sh

echo "=== Soal 8: reverse zone (tedd) ==="

CONF="/etc/bind/named.conf"

echo "[1] Persiapan directory"

mkdir -p /var/bind/slave
mkdir -p /var/run/named
chown named:named /var/bind/slave
chown named:named /var/run/named

echo "[2] Cek deklarasi reverse zone"

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa
do
    if grep -q "zone \"$z\"" "$CONF"; then
        echo "$z sudah ada"
    else
        echo "$z belum ada, menambahkan..."

        cat >> "$CONF" <<EOF

zone "$z" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/$z";
};
EOF
    fi
done

echo "[3] Cek konfigurasi"

named-checkconf "$CONF" || exit 1

echo "[4] Restart named"

pkill named 2>/dev/null
sleep 1
named -u named

echo "[5] Menunggu zone transfer"

sleep 5

echo "[6] Cek file slave"

ls -lh /var/bind/slave/

echo
echo "[7] Cek reverse query"

for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6
do
    echo "=== $ip ==="
    dig @192.225.5.3 -x "$ip" +noall +comments +answer
done

echo
echo "[8] Cek serial"

SEMUA_SAMA=1

for z in 3 4 5
do
    ZONE="$z.225.192.in-addr.arpa"

    P=$(dig @192.225.5.2 "$ZONE" SOA +short | awk '{print $3}')
    T=$(dig @192.225.5.3 "$ZONE" SOA +short | awk '{print $3}')

    echo "$ZONE : PRAB=$P TEDD=$T"

    if [ -z "$P" ] || [ -z "$T" ] || [ "$P" != "$T" ]; then
        SEMUA_SAMA=0
    fi
done

echo

if [ "$SEMUA_SAMA" -eq 1 ]; then
    echo "Serial semua reverse zone sama."
    echo "Zone transfer berhasil."
else
    echo "Serial belum sama."
    echo "Zone transfer belum selesai."
    exit 1
fi

echo
echo "=== SOAL 8 TEDD SELESAI ==="
EOT

chmod +x /root/soal8_tedd.sh
/root/soal8_tedd.sh
```
### Urutan Menjalankan Script

**1. PRAB**

```sh
chmod +x /root/soal8_prab.sh
/root/soal8_prab.sh
```
<img width="959" height="167" alt="image" src="https://github.com/user-attachments/assets/6f4ecd4f-6eb4-40a7-b900-5e6ff202a354" />

**2. TEDD**

```sh
chmod +x /root/soal8_tedd.sh
/root/soal8_tedd.sh
```
<img width="959" height="301" alt="image" src="https://github.com/user-attachments/assets/50bada9a-4dd0-46d0-801f-5bc48a55467e" />

**3. Verifikasi reverse DNS pada TEDD**

```sh
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6
do
    dig @192.225.5.3 -x "$ip" +noall +comments +answer
done
```
<img width="959" height="269" alt="image" src="https://github.com/user-attachments/assets/41fa57d3-439b-45a6-bd98-99d2ecf5957e" />

Hasil harus menunjukkan `penny.k28.com`, `abbey.k28.com`, `vault.k28.com`, dan `core.k28.com`, serta flag `aa`.

---
# SOAL 9 — WEB STATIS APACHE DAN AUTOINDEX

## Tujuan

Pada soal ini dilakukan konfigurasi web statis menggunakan Apache pada node area vault. Direktori `/arsip/` dibuat dan fitur **AutoIndex (Directory Listing)** diaktifkan agar file dan folder di dalamnya dapat ditampilkan melalui web. Pengujian dilakukan menggunakan hostname, yaitu `obladi.k28.com`, `desmond.k28.com`, dan `vault.k28.com`, bukan menggunakan IP address secara langsung.

## Langkah-Langkah

### 1. Konfigurasi Apache pada `obladi`

Masuk ke console `obladi`, kemudian install Apache dan curl.

```bash
apk update
apk add apache2 curl
```

Membuat direktori dan file untuk pengujian:

```bash
mkdir -p /arsip/laporan

echo "dokumen 1" > /arsip/dokumen1.txt
echo "dokumen 2" > /arsip/dokumen2.txt
echo "laporan a" > /arsip/laporan/a.txt
echo "dari obladi" > /arsip/server.txt

chmod -R 755 /arsip
```

### 2. Mengaktifkan AutoIndex

Membuat konfigurasi Apache:

```bash
cat > /etc/apache2/conf.d/arsip.conf <<'CONF'
ServerName localhost

Alias /arsip /arsip

<Directory "/arsip">
    Options +Indexes
    IndexOptions FancyIndexing HTMLTable NameWidth=*
    AllowOverride None
    Require all granted
</Directory>
CONF
```

Cek konfigurasi:

```bash
httpd -t
```

Hasil:

```text
Syntax OK
```

Kemudian menjalankan Apache:

```bash
ps | grep -q "[h]ttpd" && httpd -k restart || httpd
```

Pengujian menggunakan `curl`:

```bash
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"
```

Hasil:

```text
dokumen1.txt
dokumen2.txt
laporan/
```

Untuk melihat **seluruh directory listing**, dapat menggunakan:

```bash
curl http://localhost/arsip/
```

Hasil menampilkan daftar file dan folder di dalam `/arsip/`.

<img width="959" height="278" alt="image" src="https://github.com/user-attachments/assets/3f15ec04-6ca2-4bea-a101-e39dcf03c12e" />

<img width="959" height="297" alt="image" src="https://github.com/user-attachments/assets/e99a1e2b-d37a-47dd-a60a-d4ef347ada4a" />

**Konfigurasi dan hasil pengujian Apache pada `obladi`.**

<img width="959" height="209" alt="Screenshot 2026-09-30 183515" src="https://github.com/user-attachments/assets/059f4940-4dfc-4bc8-b378-138d1af5f7b8" />

### 3. Konfigurasi Apache pada `desmond`

Masuk ke console `desmond`.

```bash
apk update
apk add apache2 curl

mkdir -p /arsip/laporan

echo "dokumen 1" > /arsip/dokumen1.txt
echo "dokumen 2" > /arsip/dokumen2.txt
echo "laporan a" > /arsip/laporan/a.txt
echo "dari desmond" > /arsip/server.txt

chmod -R 755 /arsip
```

Membuat konfigurasi AutoIndex:

```bash
cat > /etc/apache2/conf.d/arsip.conf <<'CONF'
ServerName localhost

Alias /arsip /arsip

<Directory "/arsip">
    Options +Indexes
    IndexOptions FancyIndexing HTMLTable NameWidth=*
    AllowOverride None
    Require all granted
</Directory>
CONF
```

Cek konfigurasi:

```bash
httpd -t
```

Kemudian jalankan Apache:

```bash
ps | grep -q "[h]ttpd" && httpd -k restart || httpd
```

Pengujian menggunakan `curl`:

```bash
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"
```

Hasil:

```text
dokumen1.txt
dokumen2.txt
laporan/
```
<img width="959" height="75" alt="image" src="https://github.com/user-attachments/assets/375fdc88-c8d9-498b-9930-187f7b67851a" />


Untuk melihat directory listing secara lengkap:

```bash
curl http://localhost/arsip/
```
<img width="959" height="306" alt="image" src="https://github.com/user-attachments/assets/e3344afe-657d-4f68-ba38-18826e8befeb" />

<img width="959" height="275" alt="image" src="https://github.com/user-attachments/assets/c67542d1-80ac-4a30-89ac-addee208b6f2" />

**Konfigurasi dan hasil pengujian Apache pada `desmond`.**

<img width="933" height="140" alt="Screenshot 2026-09-30 183604" src="https://github.com/user-attachments/assets/a2d058cf-7769-413c-9710-eab8c22041a6" />

### 4. Pengujian Hostname dari `delta`

Pengujian dilakukan dari `delta` untuk memastikan hostname dapat digunakan.

### Di DELTA jalankan ini

```sh
cat > /etc/resolv.conf <<'EOF'
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
EOF
```

###  Cek

```sh
cat /etc/resolv.conf
```

Harus muncul:

```text
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
```

```bash
dig obladi.k28.com +short
dig desmond.k28.com +short
dig vault.k28.com +short
```

Hasil:

```text
192.225.5.4
192.225.5.5
192.225.5.4
192.225.5.5
```

Selanjutnya dilakukan pengujian web menggunakan hostname.

#### Opsi 1 — Menggunakan `curl`

Jika `curl` belum tersedia:

```bash
apk add curl
```

Kemudian:

```bash
curl -s http://obladi.k28.com/arsip/ | grep -E "dokumen|laporan"
```

```bash
curl -s http://desmond.k28.com/arsip/ | grep -E "dokumen|laporan"
```

```bash
curl -s http://vault.k28.com/arsip/ | grep -E "dokumen|laporan"
```

Hasil menampilkan:

```text
dokumen1.txt
dokumen2.txt
laporan/
```

Untuk melihat seluruh isi directory listing:

```bash
curl http://vault.k28.com/arsip/
```

Hasil:

```text
Index of /arsip

dokumen1.txt
dokumen2.txt
laporan/
server.txt
```

#### Opsi 2 — Menggunakan `lynx`

Install `lynx` pada `delta`:

```bash
apk add lynx
```

Kemudian akses menggunakan hostname:

```bash
lynx http://vault.k28.com/arsip/
```
<img width="959" height="254" alt="image" src="https://github.com/user-attachments/assets/742f373a-13ac-43f9-8eab-c2a98c23733c" />

<img width="959" height="221" alt="image" src="https://github.com/user-attachments/assets/5a1f8f10-e0af-446e-a5a2-a5215b88fa80" />

Browser teks `lynx` akan menampilkan halaman directory listing Apache. File dan folder di dalam `/arsip/` dapat dipilih dan dibuka melalui terminal.

Untuk menguji hostname secara langsung pada masing-masing server:

```bash
lynx http://obladi.k28.com/arsip/
```

```bash
lynx http://desmond.k28.com/arsip/
```

```bash
lynx http://vault.k28.com/arsip/
```

Dengan demikian, pengujian tetap dilakukan menggunakan **hostname**, bukan IP address.

**Pengujian hostname dan directory listing dari `delta`.**

<img width="950" height="300" alt="Screenshot 2026-09-30 183747" src="https://github.com/user-attachments/assets/2cfcd8e5-cb07-4a2c-b867-b0f11bf9734c" />

### 5. Pengujian Folder `laporan`

Untuk memastikan subfolder juga dapat ditelusuri:

#### Menggunakan `curl`

```bash
curl -s http://vault.k28.com/arsip/laporan/ | grep "a.txt"
```

Hasil:

```text
a.txt
```

Kemudian:

```bash
curl http://vault.k28.com/arsip/
```

Hasil menampilkan:

```text
Index of /arsip

dokumen1.txt
dokumen2.txt
laporan/
server.txt
```

#### Menggunakan `lynx`

```bash
lynx http://vault.k28.com/arsip/
```

Kemudian pilih:

```text
laporan/
```

untuk masuk ke folder `/arsip/laporan/`.

Di dalamnya terdapat:

```text
a.txt
```

**Hasil directory listing `vault.k28.com/arsip/`.**

<img width="959" height="232" alt="Screenshot 2026-09-30 184638" src="https://github.com/user-attachments/assets/0833e1a7-fa31-442d-a7b2-d29fb8cc4553" />

## Kesimpulan

Konfigurasi web statis menggunakan Apache berhasil dilakukan pada node `obladi` dan `desmond`. Fitur AutoIndex pada direktori `/arsip/` juga berhasil menampilkan daftar file dan folder.

Pengujian dilakukan menggunakan hostname `obladi.k28.com`, `desmond.k28.com`, dan `vault.k28.com` tanpa mengakses IP address secara langsung. Pengujian dapat dilakukan menggunakan `curl` maupun browser teks `lynx`, sehingga directory listing dapat ditampilkan dan folder `/arsip/laporan/` dapat ditelusuri.

## Versi Otomatis (Script)

### Node `obladi`

```bash
cat > /root/soal9_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add apache2 curl

mkdir -p /arsip/laporan

echo "dokumen 1" > /arsip/dokumen1.txt
echo "dokumen 2" > /arsip/dokumen2.txt
echo "laporan a" > /arsip/laporan/a.txt
echo "dari obladi" > /arsip/server.txt

chmod -R 755 /arsip

cat > /etc/apache2/conf.d/arsip.conf <<'CONF'
ServerName localhost

Alias /arsip /arsip

<Directory "/arsip">
    Options +Indexes
    IndexOptions FancyIndexing HTMLTable NameWidth=*
    AllowOverride None
    Require all granted
</Directory>
CONF

httpd -t || exit 1

ps | grep -q "[h]ttpd" && httpd -k restart || httpd

sleep 1

echo "=== TEST APACHE ==="
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"

echo "=== TEST SERVER ==="
curl -s http://localhost/arsip/server.txt
EOF
```

Cara menjalankannya:

```bash
chmod +x /root/soal9_setup.sh
/root/soal9_setup.sh
```

### Node `desmond`

```bash
cat > /root/soal9_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add apache2 curl

mkdir -p /arsip/laporan

echo "dokumen 1" > /arsip/dokumen1.txt
echo "dokumen 2" > /arsip/dokumen2.txt
echo "laporan a" > /arsip/laporan/a.txt
echo "dari desmond" > /arsip/server.txt

chmod -R 755 /arsip

cat > /etc/apache2/conf.d/arsip.conf <<'CONF'
ServerName localhost

Alias /arsip /arsip

<Directory "/arsip">
    Options +Indexes
    IndexOptions FancyIndexing HTMLTable NameWidth=*
    AllowOverride None
    Require all granted
</Directory>
CONF

httpd -t || exit 1

ps | grep -q "[h]ttpd" && httpd -k restart || httpd

sleep 1

echo "=== TEST APACHE ==="
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"

echo "=== TEST SERVER ==="
curl -s http://localhost/arsip/server.txt
EOF
```

Cara menjalankannya:

```bash
chmod +x /root/soal9_setup.sh
/root/soal9_setup.sh
```

## Urutan Menjalankan Script

### 1. Node `obladi`

Setelah isi `soal9_setup.sh` selesai dibuat:

```bash
chmod +x /root/soal9_setup.sh
/root/soal9_setup.sh
```

### 2. Node `desmond`

Setelah isi `soal9_setup.sh` selesai dibuat:

```bash
chmod +x /root/soal9_setup.sh
/root/soal9_setup.sh
```

### 3. Node `delta` — Pengujian DNS

Pastikan `curl` tersedia:

```bash
apk add curl
```

Kemudian lakukan pengujian hostname:

```bash
dig obladi.k28.com +short
dig desmond.k28.com +short
dig vault.k28.com +short
```

### 4. Node `delta` — Pengujian menggunakan `curl`

Pengujian dilakukan melalui hostname:

```bash
curl http://obladi.k28.com/arsip/
```

```bash
curl http://desmond.k28.com/arsip/
```

```bash
curl http://vault.k28.com/arsip/
```

Untuk pengujian yang lebih ringkas:

```bash
curl -s http://obladi.k28.com/arsip/ | grep -E "dokumen|laporan"
```

```bash
curl -s http://desmond.k28.com/arsip/ | grep -E "dokumen|laporan"
```

```bash
curl -s http://vault.k28.com/arsip/ | grep -E "dokumen|laporan"
```

### 5. Node `delta` — Install `lynx`

```bash
apk add lynx
```

### 6. Node `delta` — Pengujian menggunakan `lynx`

```bash
lynx http://obladi.k28.com/arsip/
```

Keluar dari `lynx`:

```text
q
```

Kemudian:

```bash
lynx http://desmond.k28.com/arsip/
```

Keluar:

```text
q
```

Kemudian:

```bash
lynx http://vault.k28.com/arsip/
```

Dari halaman tersebut dapat masuk ke folder `laporan/` untuk memastikan directory listing dapat ditelusuri.

---
# Soal 10 – Web Dinamis PHP-FPM dengan Nginx

## Tujuan

Percobaan ini bertujuan untuk menjalankan layanan web dinamis menggunakan **Nginx dan PHP-FPM** pada node **Oblada dan Molly** di area core. Website dibuat sederhana dengan dua halaman, yaitu halaman beranda dan halaman profil. Selain itu, diterapkan aturan rewrite agar halaman profil dapat diakses menggunakan URL `/profil` tanpa menuliskan `.php`. Pengujian dilakukan menggunakan hostname `oblada.k28.com` dan `molly.k28.com`.

## Langkah 1 – Masuk ke Node Oblada

Konfigurasi web dilakukan pada node **Oblada**.

**Console: `oblada`**

```sh
apk update
```

## Langkah 2 – Install Nginx dan PHP-FPM

Masih di console **Oblada**, install Nginx dan PHP-FPM:

```sh
apk add nginx php84 php84-fpm curl
```

Setelah proses selesai, Nginx dan PHP-FPM sudah tersedia untuk digunakan sebagai web server dan pemroses PHP.

## Langkah 3 – Membuat Direktori Website

Buat direktori untuk menyimpan file aplikasi:

```sh
mkdir -p /var/www/core
```

Cek direktori:

```sh
ls -ld /var/www/core
```

## Langkah 4 – Membuat Halaman Beranda

Buat file `index.php`:

```sh
cat > /var/www/core/index.php <<'EOF'
<?php
echo "<h1>Markas K28</h1>";
echo "<p>Halo! Selamat datang di markas kecil The Mesh.</p>";
echo "<p>Kalau error, tenang... kita juga kadang error.</p>";
echo "<p>Jangan panik, deadline cuma angka.</p>";
echo "<hr>";
echo "<p><b>May & AL | Kelompok K28</b></p>";
echo "<p>Dikelola oleh node: oblada</p>";
echo "<p><a href='/profil'>Lihat Profil Kami</a></p>";
?>
EOF
```

Cek file:

```sh
ls -l /var/www/core/
```

## Langkah 5 – Membuat Halaman Profil

Masih di **Oblada**, buat file `profil.php`:

```sh
cat > /var/www/core/profil.php <<'EOF'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: oblada</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
EOF
```

Cek kembali:

```sh
ls -l /var/www/core/
```

File yang tersedia:

```text
index.php
profil.php
```
<img width="959" height="41" alt="image" src="https://github.com/user-attachments/assets/78da3f2e-dbbc-4d73-b8d9-93d37f1455c2" />

## Langkah 6 – Menjalankan PHP-FPM

Cek terlebih dahulu apakah PHP-FPM sudah berjalan:

```sh
ps | grep php-fpm
```

Hasilnya kosong → **PHP-FPM belum berjalan**.

Lalu cek:

```sh
apk info -e php84-fpm
```

Hasilnya kosong → **PHP-FPM belum ter-install**.

Cek repository Alpine

```sh
cat /etc/apk/repositories
```

Cek koneksi internet

```sh
ping -c 3 8.8.8.8
```

**Bisa ping** → koneksi internet/IP OBLADA sebenarnya normal.

Cek DNS

```sh
ping -c 3 dl-cdn.alpinelinux.org
```

Awalnya **`try again`** → berarti DNS OBLADA bermasalah.

Perbaiki `/etc/resolv.conf`

Kita isi:

```sh
cat > /etc/resolv.conf <<'EOF'
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
EOF
```

Artinya OBLADA akan mencoba DNS:

```text
PRAB       → 192.225.5.2
TEDD       → 192.225.5.3
Gateway    → 192.168.122.1
```

Kemudian:

```sh
ping -c 3 dl-cdn.alpinelinux.org
```

**Berhasil** → DNS sudah normal.

Update repository lagi

Setelah DNS normal:

```sh
apk update
```

Jika belum berjalan, jalankan:
```
apk add php84 php84-fpm
```
```sh
php-fpm84
```

Kemudian cek port PHP-FPM:

```sh
netstat -tlnp 2>/dev/null | grep 9000
```

Jika muncul:

```text
127.0.0.1:9000
```

berarti PHP-FPM sudah berjalan.

<img width="949" height="97" alt="Screenshot 2026-09-30 214729" src="https://github.com/user-attachments/assets/1958bfc0-556e-42bb-909d-0ef6a156a7f9" />

## Langkah 7 – Membuat Konfigurasi Nginx

Buat direktori konfigurasi:

```sh
mkdir -p /etc/nginx/http.d
```

Kemudian buat konfigurasi:

```sh
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name oblada.k28.com;

    root /var/www/core;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }
}
EOF
```

Konfigurasi tersebut membuat hostname `oblada.k28.com` menggunakan direktori `/var/www/core`. Bagian rewrite digunakan agar `/profil` diarahkan ke `profil.php`.

## Langkah 8 – Mengecek Konfigurasi Nginx

Jalankan:
```
apk add nginx
```

```sh
nginx -t
```

Jika muncul:

```text
syntax is ok
test is successful
```

berarti konfigurasi Nginx berhasil.

## Langkah 9 – Menjalankan Nginx

Cek terlebih dahulu apakah Nginx sudah berjalan:

```sh
ps | grep -q "[n]ginx"
```

Jika belum berjalan:

```sh
nginx
```

Jika sudah berjalan:

```sh
nginx -s reload
```

Kemudian cek port 80:

```sh
netstat -tlnp 2>/dev/null | grep ':80'
```

Pastikan proses yang menggunakan port 80 adalah Nginx.

## Langkah 10 – Pengujian Beranda pada Node Oblada

Masih di console **Oblada**, pengujian dilakukan menggunakan hostname dengan header Host:

```sh
curl -s -H "Host: oblada.k28.com" http://127.0.0.1/
```

Hasil beranda menampilkan:

```text
Markas K28

Halo! Selamat datang di markas kecil The Mesh.
Kalau error, tenang... kita juga kadang error.
Jangan panik, deadline cuma angka.

May & AL | Kelompok K28
Dikelola oleh node: oblada
Lihat Profil Kami
```

## Langkah 11 – Pengujian dari Node Delta

Pengujian dari node lain dilakukan menggunakan hostname.

**Console: `delta`**

### Opsi 1 — Menggunakan `curl`

Jika `curl` belum tersedia:

```sh
apk add curl
```

Kemudian akses halaman beranda:

```sh
curl http://oblada.k28.com/
```

Untuk menguji halaman profil:

```sh
curl http://oblada.k28.com/profil
```

Jika hasil halaman profil muncul, berarti aturan rewrite `/profil` berhasil.

### Opsi 2 — Menggunakan `lynx`

Jika `lynx` belum tersedia:

```sh
apk add lynx
```

Kemudian akses halaman beranda:

```sh
lynx -reload http://oblada.k28.com/
```
<img width="959" height="286" alt="image" src="https://github.com/user-attachments/assets/e2255d12-48e4-4d6b-aca0-f04c2d38f9fd" />

<img width="959" height="286" alt="image" src="https://github.com/user-attachments/assets/e12e0076-b66b-4f11-b391-a6a4ea989ecd" />

Untuk halaman profil:

```sh
lynx -reload http://oblada.k28.com/profil
```

Pengujian tersebut menggunakan hostname `oblada.k28.com`, bukan IP address.

## Langkah 12 – Pengujian URL Bersih `/profil`

Masih di **Delta**, jalankan:

```sh
curl http://oblada.k28.com/profil
```

Hasilnya menampilkan:

```text
Profil Kelompok

May & AL
Kelompok K28 - The Mesh
Node: oblada
Kembali ke Beranda
```

Walaupun file sebenarnya bernama `profil.php`, halaman dapat diakses menggunakan:

```text
http://oblada.k28.com/profil
```

tanpa `.php`.

Pengujian yang sama menggunakan Lynx:

```sh
lynx -reload http://oblada.k28.com/profil
```

## Langkah 13 – Konfigurasi Node Molly

Karena node **Molly** juga merupakan bagian dari area core, konfigurasi web dinamis dibuat pada Molly.

**Console: `molly`**

Install paket:

```sh
apk update
apk add nginx php84 php84-fpm curl
```

Buat direktori:

```sh
mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d
```

Buat halaman beranda:

```sh
cat > /var/www/core/index.php <<'EOF'
<?php
echo "<h1>Markas K28</h1>";
echo "<p>Halo! Selamat datang di markas kecil The Mesh.</p>";
echo "<p><b>May & AL | Kelompok K28</b></p>";
echo "<p>Dikelola oleh node: molly</p>";
echo "<p><a href='/profil'>Lihat Profil Kami</a></p>";
?>
EOF
```

Buat halaman profil:

```sh
cat > /var/www/core/profil.php <<'EOF'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: molly</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
EOF
```

Jalankan PHP-FPM jika belum aktif:

```sh
ps | grep -q "[p]hp-fpm84" || php-fpm84
```

Buat konfigurasi Nginx:

```sh
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name molly.k28.com;

    root /var/www/core;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }
}
EOF
```

Cek konfigurasi:

```sh
nginx -t
```

Jika berhasil:

```text
syntax is ok
test is successful
```

Jalankan atau reload Nginx:

```sh
ps | grep -q "[n]ginx" && nginx -s reload || nginx
```

## Langkah 14 – Pengujian Molly dari Delta

Pengujian dilakukan melalui hostname `molly.k28.com`.

### Opsi 1 — `curl`

```sh
curl http://molly.k28.com/
```

Kemudian:

```sh
curl http://molly.k28.com/profil
```

### Opsi 2 — `lynx`

```sh
lynx -reload http://molly.k28.com/
```

Kemudian:

```sh
lynx -reload http://molly.k28.com/profil
```

Hasil halaman profil:

```text
Profil Kelompok

May & AL
Kelompok K28 - The Mesh
Node: molly
Kembali ke Beranda
```

Dengan demikian, halaman Molly juga dapat diakses menggunakan URL bersih:

```text
http://molly.k28.com/profil
```

## Kesimpulan

Berdasarkan konfigurasi dan pengujian yang dilakukan, layanan web dinamis berhasil dijalankan menggunakan **Nginx dan PHP-FPM** pada node **Oblada dan Molly** di area core. Website memiliki halaman beranda dan halaman profil.

Aturan rewrite berhasil membuat halaman profil dapat diakses menggunakan URL bersih `/profil` tanpa akhiran `.php`. Pengujian dilakukan menggunakan hostname `oblada.k28.com` dan `molly.k28.com` melalui `curl` maupun `lynx`, bukan menggunakan IP address secara langsung.

## Versi Otomatis (Script)

### Node `oblada`

Buat script:

```sh
cat > /root/soal10_setup.sh <<'EOF'
#!/bin/sh

echo "=== SOAL 10 - OBLADA ==="

echo "[1] INSTALL NGINX PHP-FPM"
apk update
apk add nginx php84 php84-fpm curl

echo "[2] DIREKTORI WEBSITE"
mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d

echo "[3] INDEX.PHP"
cat > /var/www/core/index.php <<'PHP'
<?php
echo "<h1>Markas K28</h1>";
echo "<p>Halo! Selamat datang di markas kecil The Mesh.</p>";
echo "<p>Kalau error, tenang... kita juga kadang error.</p>";
echo "<p>Jangan panik, deadline cuma angka.</p>";
echo "<hr>";
echo "<p><b>May & AL | Kelompok K28</b></p>";
echo "<p>Dikelola oleh node: oblada</p>";
echo "<p><a href='/profil'>Lihat Profil Kami</a></p>";
?>
PHP

echo "[4] PROFIL.PHP"
cat > /var/www/core/profil.php <<'PHP'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: oblada</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
PHP

echo "[5] KONFIGURASI NGINX"
cat > /etc/nginx/http.d/core.conf <<'NGINX'
server {
    listen 80;
    server_name oblada.k28.com;

    root /var/www/core;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }
}
NGINX

echo "[6] PHP-FPM"
ps | grep -q "[p]hp-fpm84" || php-fpm84

echo "[7] CEK NGINX"
nginx -t || exit 1

echo "[8] JALANKAN / RELOAD NGINX"
if ps | grep -q "[n]ginx"; then
    nginx -s reload
else
    nginx
fi

echo "[9] TEST"
curl -s http://oblada.k28.com/ | grep -E "Markas K28|May & AL"
curl -s http://oblada.k28.com/profil | grep -E "Profil Kelompok|May & AL"

echo "=== SOAL 10 OBLADA SELESAI ==="
EOF
```

Cara menjalankannya:

```sh
chmod +x /root/soal10_setup.sh
/root/soal10_setup.sh
```

### Node `molly`

Buat script:

```sh
cat > /root/soal10_setup.sh <<'EOF'
#!/bin/sh

echo "=== SOAL 10 - MOLLY ==="

echo "[1] INSTALL NGINX PHP-FPM"
apk update
apk add nginx php84 php84-fpm curl

echo "[2] DIREKTORI WEBSITE"
mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d

echo "[3] INDEX.PHP"
cat > /var/www/core/index.php <<'PHP'
<?php
echo "<h1>Markas K28</h1>";
echo "<p>Halo! Selamat datang di markas kecil The Mesh.</p>";
echo "<p>Kalau error, tenang... kita juga kadang error.</p>";
echo "<p>Jangan panik, deadline cuma angka.</p>";
echo "<hr>";
echo "<p><b>May & AL | Kelompok K28</b></p>";
echo "<p>Dikelola oleh node: molly</p>";
echo "<p><a href='/profil'>Lihat Profil Kami</a></p>";
?>
PHP

echo "[4] PROFIL.PHP"
cat > /var/www/core/profil.php <<'PHP'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: molly</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
PHP

echo "[5] KONFIGURASI NGINX"
cat > /etc/nginx/http.d/core.conf <<'NGINX'
server {
    listen 80;
    server_name molly.k28.com;

    root /var/www/core;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }
}
NGINX

echo "[6] PHP-FPM"
ps | grep -q "[p]hp-fpm84" || php-fpm84

echo "[7] CEK NGINX"
nginx -t || exit 1

echo "[8] JALANKAN / RELOAD NGINX"
if ps | grep -q "[n]ginx"; then
    nginx -s reload
else
    nginx
fi

echo "[9] TEST"
curl -s http://molly.k28.com/ | grep -E "Markas K28|May & AL"
curl -s http://molly.k28.com/profil | grep -E "Profil Kelompok|May & AL"

echo "=== SOAL 10 MOLLY SELESAI ==="
EOF
```

Cara menjalankannya:

```sh
chmod +x /root/soal10_setup.sh
/root/soal10_setup.sh
```

### Pengujian Hostname dari `delta`

Setelah Oblada dan Molly selesai dikonfigurasi, pengujian dilakukan dari `delta`.

#### Opsi 1 — `curl`

```sh
curl http://oblada.k28.com/
curl http://oblada.k28.com/profil

curl http://molly.k28.com/
curl http://molly.k28.com/profil
```

Jika ingin hasil lebih ringkas:

```sh
curl -s http://oblada.k28.com/profil | grep "Profil Kelompok"
curl -s http://molly.k28.com/profil | grep "Profil Kelompok"
```

#### Opsi 2 — `lynx`

Jika belum tersedia:

```sh
apk add lynx
```

Kemudian:

```sh
lynx -reload http://oblada.k28.com/
lynx -reload http://oblada.k28.com/profil
```

dan:

```sh
lynx -reload http://molly.k28.com/
lynx -reload http://molly.k28.com/profil
```

URL yang digunakan dalam pengujian:

```text
http://oblada.k28.com/
http://oblada.k28.com/profil

http://molly.k28.com/
http://molly.k28.com/profil
```

Tidak ada pengujian menggunakan IP address secara langsung.

# Soal 11 – Reverse Proxy & Load Balancing

## Tujuan

Percobaan ini bertujuan untuk menerapkan **reverse proxy dan load balancing** pada dua area jaringan, yaitu **Vault** dan **Core**.

Konfigurasi yang dibuat:

* **Penny** menggunakan Apache sebagai reverse proxy dan load balancer untuk area Vault.

  * Obladi `192.225.5.4`
  * Desmond `192.225.5.5`
* **Abbey** menggunakan Nginx sebagai reverse proxy dan load balancer untuk area Core.

  * Oblada `192.225.5.6`
  * Molly `192.225.5.7`

Selain melakukan load balancing, kedua gateway dikonfigurasi agar meneruskan informasi pengunjung menggunakan header:

```text
Host
X-Real-IP
```

---

# Bagian A – Apache Reverse Proxy pada Penny

## Langkah 1 – Install Apache

Konfigurasi dilakukan pada node **Penny**.

**Console: `penny`**

Update repository dan install Apache beserta modul proxy:

```sh
apk update
apk add apache2 apache2-openrc apache2-proxy
```

Cek versi Apache:

```sh
httpd -v
```

---

## Langkah 2 – Membuat Konfigurasi Load Balancer

Buat konfigurasi Apache:

```sh
cat > /etc/apache2/conf.d/vault-proxy.conf <<'EOF'
<Proxy "balancer://vault">
    BalancerMember "http://192.225.5.4"
    BalancerMember "http://192.225.5.5"
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPreserveHost On

ProxyPass "/" "balancer://vault/"
ProxyPassReverse "/" "balancer://vault/"

RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
EOF
```

Konfigurasi tersebut membuat Penny meneruskan request ke:

```text
192.225.5.4 → Obladi
192.225.5.5 → Desmond
```

Load balancing menggunakan metode `byrequests`.

`ProxyPreserveHost On` digunakan agar header `Host` dari client tetap diteruskan ke backend.

Sedangkan:

```apache
RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
```

digunakan untuk meneruskan IP pengunjung melalui header `X-Real-IP`.

---

## Langkah 3 – Mengecek Konfigurasi Apache

Jalankan:

```sh
httpd -t -f /etc/apache2/httpd.conf
```

Jika muncul:

```text
Syntax OK
```

berarti konfigurasi berhasil.

---

## Langkah 4 – Menjalankan Apache

Pada Penny, jalankan:

```sh
httpd -f /etc/apache2/httpd.conf
```

Kemudian cek port 80:

```sh
ss -lntp | grep ':80'
```

> **Catatan:** Pada Penny sebelumnya terdapat BusyBox `httpd` yang menggunakan port 80. Jika muncul `Address in use`, proses `httpd` lama harus dihentikan terlebih dahulu sebelum menjalankan Apache.

---

## Langkah 5 – Pengujian Backend Vault

Sebelum menguji load balancing, backend diperiksa terlebih dahulu.

### Backend Obladi

Dari Penny:

```sh
wget -q -O- http://192.225.5.4/
```

Hasil:

```text
<h1>OBLADI - VAULT</h1>
```

### Backend Desmond

```sh
wget -q -O- http://192.225.5.5/
```

Hasil:

```text
<h1>DESMOND - VAULT</h1>
```

Kedua backend dapat diakses dari Penny.

---

# Bagian B – Backend Vault

## Langkah 6 – Konfigurasi Node Obladi

**Console: `obladi`**

Install Nginx:

```sh
apk update
apk add nginx
```

Buat halaman backend:

```sh
mkdir -p /var/lib/nginx/html

echo '<h1>OBLADI - VAULT</h1>' > /var/lib/nginx/html/index.html
```

Kemudian buat konfigurasi Nginx:

```sh
cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        root /var/lib/nginx/html;
        index index.html;
    }
}
EOF
```

Cek konfigurasi:

```sh
nginx -t
```

Jalankan Nginx:

```sh
nginx
```

Tes:

```sh
wget -q -O- http://127.0.0.1/
```

Hasil:

```text
<h1>OBLADI - VAULT</h1>
```

---

## Langkah 7 – Konfigurasi Node Desmond

**Console: `desmond`**

Install Nginx:

```sh
apk update
apk add nginx
```

Buat halaman backend:

```sh
mkdir -p /var/lib/nginx/html

echo '<h1>DESMOND - VAULT</h1>' > /var/lib/nginx/html/index.html
```

Buat konfigurasi:

```sh
cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        root /var/lib/nginx/html;
        index index.html;
    }
}
EOF
```

Cek konfigurasi:

```sh
nginx -t
```

Jalankan:

```sh
nginx
```

Tes:

```sh
wget -q -O- http://127.0.0.1/
```

Hasil:

```text
<h1>DESMOND - VAULT</h1>
```

---

# Bagian C – Pengujian Load Balancing Penny

## Langkah 8 – Menguji Distribusi Request

Kembali ke **Penny**.

Jalankan beberapa request:

```sh
for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done
```

Hasil request menunjukkan bahwa traffic diteruskan ke backend yang berbeda, yaitu:

```text
<h1>OBLADI - VAULT</h1>
```

dan:

```text
<h1>DESMOND - VAULT</h1>
```

Hal ini membuktikan bahwa Penny berhasil melakukan load balancing ke kedua backend Vault.

<img width="748" height="470" alt="Screenshot 2026-09-30 221644" src="https://github.com/user-attachments/assets/1b828fee-0389-43a2-b8c3-5a2e0901b6ad" />


```markdown
![Load balancing Penny](screenshots/penny-load-balancing.png)
```

---

## Langkah 9 – Verifikasi Header Penny

Untuk memastikan header `Host` dan `X-Real-IP` dikonfigurasi:

```sh
grep -E 'ProxyPreserveHost|X-Real-IP' /etc/apache2/conf.d/vault-proxy.conf
```

Hasil:

```text
ProxyPreserveHost On
RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
```

<img width="740" height="368" alt="Screenshot 2026-09-30 221613" src="https://github.com/user-attachments/assets/747424fb-762a-4ced-aa2c-8099d72c84a2" />


```markdown
![Header Penny](screenshots/penny-header.png)
```

---

# Bagian D – Nginx Reverse Proxy pada Abbey

## Langkah 10 – Membuat Konfigurasi Abbey

Konfigurasi dilakukan pada node **Abbey**.

**Console: `abbey`**

Jika Nginx belum tersedia:

```sh
apk update
apk add nginx
```

Buat konfigurasi:

```sh
cat > /etc/nginx/http.d/default.conf <<'EOF'
upstream core_backend {
    server 192.225.5.6;
    server 192.225.5.7;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
```

Konfigurasi tersebut membuat Abbey meneruskan request ke:

```text
192.225.5.6 → Oblada
192.225.5.7 → Molly
```

Header yang diteruskan:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
```

---

## Langkah 11 – Mengecek dan Reload Nginx

Cek konfigurasi:

```sh
nginx -t
```

Jika muncul:

```text
syntax is ok
test is successful
```

reload Nginx:

```sh
nginx -s reload
```

<img width="1285" height="174" alt="WhatsApp Image 2026-09-30 at 22 45 46" src="https://github.com/user-attachments/assets/06b16f53-0920-4833-bbbe-f62b7931d5c9" />


```markdown
![Nginx test Abbey](screenshots/abbey-nginx-test.png)
```

---

# Bagian E – Backend Core

## Langkah 12 – Pengujian Backend Oblada

Backend Core pertama adalah **Oblada**:

```text
192.225.5.6
```

Website pada Oblada sudah dikonfigurasi pada soal sebelumnya sehingga tidak perlu diganti untuk Soal 11.

Dari Abbey:

```sh
wget -q -O- http://192.225.5.6/
```

Hasil menampilkan halaman yang dikelola oleh:

```text
node: oblada
```

Konfigurasi sebelumnya tetap dipertahankan.

---

## Langkah 13 – Pengujian Backend Molly

Backend Core kedua adalah **Molly**:

```text
192.225.5.7
```

Dari Abbey:

```sh
wget -q -O- http://192.225.5.7/
```

Hasil menampilkan halaman yang dikelola oleh:

```text
node: molly
```

Konfigurasi sebelumnya juga tetap dipertahankan.

---

# Bagian F – Pengujian Load Balancing Abbey

## Langkah 14 – Menguji Distribusi Request

Pada console **Abbey**, jalankan:

```sh
for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done
```

Hasil pengujian menunjukkan request diteruskan ke:

```text
node: oblada
```

dan:

```text
node: molly
```
 hasil yang diperoleh:

<img width="773" height="610" alt="Screenshot 2026-09-30 221720" src="https://github.com/user-attachments/assets/281935e1-7d39-47cf-a5e9-0245a564591f" />

Hasil tersebut membuktikan bahwa Abbey berhasil meneruskan traffic ke kedua backend Core.

```markdown
![Load balancing Abbey](screenshots/abbey-load-balancing.png)
```

---

## Langkah 15 – Verifikasi Header Abbey

Jalankan:

```sh
grep -E 'proxy_set_header (Host|X-Real-IP)' /etc/nginx/http.d/default.conf
```

Hasil:

```text
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
```

Konfigurasi tersebut memastikan informasi `Host` dan `X-Real-IP` diteruskan oleh Abbey ke backend.

<img width="773" height="610" alt="Screenshot 2026-09-30 221720" src="https://github.com/user-attachments/assets/b7f3868c-69f3-4b4a-8b0f-d51c4589a7fe" />


```markdown
![Header Abbey](screenshots/abbey-header.png)
```

---

# Kesimpulan

Berdasarkan konfigurasi dan pengujian yang dilakukan, reverse proxy dan load balancing berhasil diterapkan pada area **Vault** dan **Core**.

Pada area Vault, **Penny** menggunakan Apache sebagai reverse proxy dan load balancer untuk meneruskan request ke:

```text
Obladi  → 192.225.5.4
Desmond → 192.225.5.5
```

Pengujian beberapa request menunjukkan bahwa traffic dapat diteruskan ke kedua backend.

Pada area Core, **Abbey** menggunakan Nginx sebagai reverse proxy dan load balancer untuk meneruskan request ke:

```text
Oblada → 192.225.5.6
Molly  → 192.225.5.7
```

Pengujian juga menunjukkan bahwa kedua backend menerima request.

Selain itu, kedua gateway telah dikonfigurasi untuk meneruskan header:

```text
Host
X-Real-IP
```

Dengan demikian, konfigurasi reverse proxy, load balancing, dan forwarding header pada Soal 11 berhasil diterapkan.

---

# Versi Otomatis (Script)

## Node `obladi`

```sh
cat > soal11_obladi.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx

mkdir -p /var/lib/nginx/html

echo '<h1>OBLADI - VAULT</h1>' > /var/lib/nginx/html/index.html

cat > /etc/nginx/http.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        root /var/lib/nginx/html;
        index index.html;
    }
}
NGINX

nginx -t || exit 1
nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 11 OBLADI SELESAI ==="
wget -q -O- http://127.0.0.1/
echo
EOF

chmod +x soal11_obladi.sh
./soal11_obladi.sh
```

---

## Node `desmond`

```sh
cat > soal11_desmond.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx

mkdir -p /var/lib/nginx/html

echo '<h1>DESMOND - VAULT</h1>' > /var/lib/nginx/html/index.html

cat > /etc/nginx/http.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        root /var/lib/nginx/html;
        index index.html;
    }
}
NGINX

nginx -t || exit 1
nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 11 DESMOND SELESAI ==="
wget -q -O- http://127.0.0.1/
echo
EOF

chmod +x soal11_desmond.sh
./soal11_desmond.sh
```

---

## Node `penny`

```sh
cat > soal11_penny.sh <<'EOF'
#!/bin/sh

apk update
apk add apache2 apache2-openrc apache2-proxy

cat > /etc/apache2/conf.d/vault-proxy.conf <<'APACHE'
<Proxy "balancer://vault">
    BalancerMember "http://192.225.5.4"
    BalancerMember "http://192.225.5.5"
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPreserveHost On

ProxyPass "/" "balancer://vault/"
ProxyPassReverse "/" "balancer://vault/"

RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
APACHE

httpd -t -f /etc/apache2/httpd.conf || exit 1

echo "=== TEST OBLADI ==="
wget -q -O- http://192.225.5.4/
echo

echo "=== TEST DESMOND ==="
wget -q -O- http://192.225.5.5/
echo

echo "=== HEADER ==="
grep -E 'ProxyPreserveHost|X-Real-IP' /etc/apache2/conf.d/vault-proxy.conf

httpd -f /etc/apache2/httpd.conf

echo "=== LOAD BALANCING ==="

for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done

echo "=== SOAL 11 PENNY SELESAI ==="
EOF

chmod +x soal11_penny.sh
./soal11_penny.sh
```

> **Catatan:** Jika port 80 masih digunakan oleh BusyBox `httpd`, hentikan proses tersebut terlebih dahulu sebelum menjalankan Apache.

---

## Node `abbey`

```sh
cat > soal11_abbey.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx

cat > /etc/nginx/http.d/default.conf <<'NGINX'
upstream core_backend {
    server 192.225.5.6;
    server 192.225.5.7;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

nginx -t || exit 1

nginx 2>/dev/null || nginx -s reload

echo "=== TEST OBLADA ==="
wget -q -O- http://192.225.5.6/
echo

echo "=== TEST MOLLY ==="
wget -q -O- http://192.225.5.7/
echo

echo "=== HEADER ==="
grep -E 'proxy_set_header (Host|X-Real-IP)' /etc/nginx/http.d/default.conf

echo "=== LOAD BALANCING ==="

for i in 1 2 3 4 5 6; do
    echo "=== Request $i ==="
    wget -q -O- http://127.0.0.1/
    echo
done

echo "=== SOAL 11 ABBEY SELESAI ==="
EOF

chmod +x soal11_abbey.sh
./soal11_abbey.sh
```

> **Catatan:** Script Abbey hanya mengatur reverse proxy pada Abbey. Konfigurasi website yang sudah ada pada Oblada dan Molly dari soal sebelumnya tetap dipertahankan.

---
# Soal 12 – Basic Authentication pada `/admin`

## Tujuan

Menerapkan **Basic Authentication** pada path `/admin` di node `penny` agar hanya pengguna dengan credential yang benar yang dapat mengaksesnya.

---

## 1. Membuat Direktori `/admin`

**Node: `penny`**

Buat direktori untuk halaman admin:

```sh
mkdir -p /var/www/localhost/htdocs/admin
```

Kemudian buat halaman admin sederhana:

```sh
echo "<h1>Admin Penny</h1><p>Dokumen rahasia sindikat.</p>" > /var/www/localhost/htdocs/admin/index.html
```

Cek hasilnya:

```sh
cat /var/www/localhost/htdocs/admin/index.html
```

## 2. Membuat User untuk Basic Authentication

Install utility `htpasswd`:

```sh
apk add apache2-utils
```

Kemudian buat user `prabs`:

```sh
htpasswd -c /etc/apache2/.htpasswd prabs
```

Masukkan password sesuai soal ketika diminta.

Jika berhasil akan muncul:

```text
Adding password for user prabs
```


## 3. Konfigurasi Basic Authentication

Edit konfigurasi Apache:

```sh
cat >> /etc/apache2/httpd.conf <<'EOF'

<Directory "/var/www/localhost/htdocs/admin">
    AuthType Basic
    AuthName "Area Rahasia"
    AuthUserFile "/etc/apache2/.htpasswd"
    Require valid-user
</Directory>
EOF
```

Keterangan konfigurasi:

* `AuthType Basic` → menggunakan Basic Authentication.
* `AuthName` → nama area autentikasi.
* `AuthUserFile` → lokasi file username dan password.
* `Require valid-user` → hanya user yang memiliki credential valid yang dapat masuk.

Cek konfigurasi:

```sh
httpd -t
```

Hasil yang diharapkan:

```text
Syntax OK
```

## 4. Mengecualikan `/admin` dari Reverse Proxy

Pada `penny`, terdapat konfigurasi reverse proxy untuk area vault. Konfigurasi tersebut menggunakan:

```text
ProxyPass "/" "balancer://vault/"
```

Agar `/admin` tidak diteruskan ke backend vault, tambahkan pengecualian `/admin`.

Buat ulang konfigurasi:

```sh
cat > /etc/apache2/conf.d/vault-proxy.conf <<'EOF'
<Proxy "balancer://vault">
    BalancerMember "http://192.225.5.4"
    BalancerMember "http://192.225.5.5"
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPreserveHost On

ProxyPass "/admin" "!"
ProxyPass "/" "balancer://vault/"
ProxyPassReverse "/" "balancer://vault/"

RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
EOF
```

Pengecualian:

```text
ProxyPass "/admin" "!"
```

digunakan agar request `/admin` ditangani langsung oleh Apache `penny`, bukan diteruskan ke backend vault.

## 5. Restart Apache

Restart Apache:

```sh
httpd -k restart
```

## 6. Pengujian Tanpa Credential

Pengujian dilakukan menggunakan hostname `penny.k28.com`:

```sh
curl -i -H "Host: penny.k28.com" http://192.225.3.3/admin/
```

**Akses tanpa credential ditolak**

<img width="959" height="236" alt="Screenshot 2026-09-30 225211" src="https://github.com/user-attachments/assets/00d19062-bd98-4472-90d7-e263834350cc" />

Hasil yang diperoleh:

```text
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Area Rahasia"
Server: Apache/2.4.68
```

Hal ini menunjukkan bahwa pengguna tanpa credential tidak dapat mengakses `/admin`.

## 7. Pengujian dengan Credential yang Benar

Gunakan username `prabs` dan password sesuai soal:

```sh
curl -i -H "Host: penny.k28.com" -u 'prabs:PA​​SSWORD' http://192.225.3.3/admin/
```

**Akses dengan credential berhasil**

<img width="946" height="187" alt="Screenshot 2026-09-30 225510" src="https://github.com/user-attachments/assets/14e27883-5ae5-4b02-a428-6233f7256286" />

Hasil pengujian:

```text
HTTP/1.1 200 OK
Server: Apache/2.4.68
```

Halaman yang ditampilkan:

```text
Admin Penny
Dokumen rahasia sindikat.
```

Hasil tersebut menunjukkan bahwa user dengan credential yang benar berhasil mengakses halaman `/admin`.

---

## Kesimpulan

Basic Authentication berhasil diterapkan pada path `/admin` di node `penny`. Akses tanpa credential menghasilkan **401 Unauthorized**, sedangkan akses menggunakan credential `prabs` berhasil menghasilkan **200 OK**. Path `/admin` juga telah dikecualikan dari reverse proxy sehingga dapat dilayani langsung oleh Apache pada `penny`.

# LAPORAN PRAKTIKUM — SOAL 13

## Konfigurasi Redirect Web Server Penny dan Abbey

### 1. Tujuan

Pada soal nomor 13 dilakukan konfigurasi redirect pada server Penny dan Abbey dengan ketentuan:

* Server **Penny** dengan IP `192.225.3.3` menggunakan redirect **301 Moved Permanently** menuju `http://www.k28.com/`.
* Server **Abbey** dengan IP `192.225.4.2` menggunakan redirect **302 Moved Temporarily** menuju `http://static.k28.com/`.

---

# 2. Konfigurasi Server Penny

## 2.1 Mengecek IP Address Penny

Perintah:

```bash
ip addr
```

IP address Penny yang diperoleh:

```text
192.225.3.3
```

## 2.2 Mengecek Web Server Penny

Perintah:

```bash
httpd -v
```

Penny menggunakan Apache dengan versi:

```text
Apache/2.4.68 (Unix)
```

## 2.3 Mengecek dan Mengaktifkan Modul Rewrite

Konfigurasi Apache diperiksa dengan:

```bash
httpd -t
```

Hasil menunjukkan:

```text
Syntax OK
```

Kemudian lokasi `mod_rewrite` dicari:

```bash
find / -name 'mod_rewrite.so' 2>/dev/null
```

Diperoleh:

```text
/usr/lib/apache2/mod_rewrite.so
```

Modul kemudian diaktifkan dengan:

```bash
echo 'LoadModule rewrite_module /usr/lib/apache2/mod_rewrite.so' > /etc/apache2/conf.d/rewrite.conf
```

## 2.4 Membuat Konfigurasi Redirect Penny

File konfigurasi:

```text
/etc/apache2/conf.d/redirect.conf
```

Isi konfigurasi:

```apache
<VirtualHost *:80>
    ServerName penny.k28.com

    RewriteEngine On
    RewriteRule ^/(.*)$ http://www.k28.com/$1 [R=301,L]
</VirtualHost>
```

Konfigurasi tersebut membuat redirect permanen menggunakan HTTP status **301**.

Setelah konfigurasi selesai, Apache direstart:

```bash
httpd -k restart
```

## 2.5 Pengujian Redirect Penny

Perintah pengujian:

```bash
curl -I -H "Host: penny.k28.com" http://192.225.3.3/
```

Hasil:

```text
HTTP/1.1 301 Moved Permanently
Location: http://www.k28.com/
```

<img width="569" height="158" alt="Screenshot 2026-09-30 234350" src="https://github.com/user-attachments/assets/30e13795-17eb-4953-a16b-0024b427f013" />


Hasil tersebut membuktikan bahwa request ke Penny berhasil diarahkan secara permanen ke `http://www.k28.com/`.

---


# 3. Konfigurasi Server Abbey

## 3.1 Mengecek IP Address Abbey

Perintah:

```bash
ip addr
```

IP address Abbey yang diperoleh:

```text
192.225.4.2
```

## 3.2 Mengecek Web Server Abbey

Percobaan pengecekan Apache:

```bash
httpd -v
```

menghasilkan pesan:

```text
httpd: bind: Address in use
```

Kemudian dilakukan pengecekan port 80:

```bash
ss -lntp | grep ':80'
```

Hasil menunjukkan bahwa port 80 digunakan oleh **Nginx**.

Versi Nginx kemudian diperiksa:

```bash
nginx -v
```

Hasil:

```text
nginx version: nginx/1.28.3
```

## 3.3 Mengecek Konfigurasi Nginx

Konfigurasi Nginx diperiksa menggunakan:

```bash
nginx -T 2>&1 | grep -n "server_name"
```

Ditemukan konfigurasi pada:

```text
/etc/nginx/http.d/default.conf
```

## 3.4 Membuat Konfigurasi Redirect Abbey

File konfigurasi dibuka menggunakan:

```bash
vi /etc/nginx/http.d/default.conf
```

Kemudian ditambahkan konfigurasi:

```nginx
server {
    listen 80 default_server;
    server_name abbey.k28.com;

    return 302 http://static.k28.com/;
}
```

Konfigurasi tersebut membuat redirect sementara menggunakan HTTP status **302** menuju:

```text
http://static.k28.com/
```

Setelah konfigurasi selesai, dilakukan pengecekan:

```bash
nginx -t
```

Hasil:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Kemudian konfigurasi diterapkan:

```bash
nginx -s reload
```

## 3.5 Pengujian Redirect Abbey Menggunakan Domain

Perintah:

```bash
curl -I -H "Host: abbey.k28.com" http://192.225.4.2/
```

Hasil:

```text
HTTP/1.1 302 Moved Temporarily
Location: http://static.k28.com/
```
<img width="578" height="251" alt="Screenshot 2026-09-30 234431" src="https://github.com/user-attachments/assets/7a4f26d1-6272-4509-b1c0-fb677ed7ad3a" />


Hasil tersebut membuktikan bahwa `abbey.k28.com` berhasil diarahkan sementara ke `http://static.k28.com/`.

## 3.6 Pengujian Redirect Abbey Menggunakan IP

Perintah:

```bash
curl -I http://192.225.4.2/
```

Hasil:

```text
HTTP/1.1 302 Moved Temporarily
Location: http://static.k28.com/
```

<img width="728" height="316" alt="Screenshot 2026-09-30 234416" src="https://github.com/user-attachments/assets/083f283e-5819-4361-b74b-c9448d5886e6" />


Hasil tersebut membuktikan bahwa akses langsung menggunakan IP Abbey juga berhasil diarahkan sementara ke `http://static.k28.com/`.

---
### Script Konfigurasi Penny

Script konfigurasi Penny disimpan pada:

```text
/root/soal13_penny.sh
```

Isi script:

```bash
#!/bin/sh

# Mengaktifkan mod_rewrite
echo 'LoadModule rewrite_module /usr/lib/apache2/mod_rewrite.so' > /etc/apache2/conf.d/rewrite.conf

# Membuat konfigurasi redirect Penny
cat > /etc/apache2/conf.d/redirect.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k28.com

    RewriteEngine On
    RewriteRule ^/(.*)$ http://www.k28.com/$1 [R=301,L]
</VirtualHost>
EOF

# Mengecek konfigurasi dan restart Apache
httpd -t && httpd -k restart

echo "=== Soal 13 Penny selesai ==="
```

Script dibuat executable menggunakan:

```bash
chmod +x /root/soal13_penny.sh
```

---

### Script Konfigurasi Abbey

Script konfigurasi Abbey disimpan pada:

```text
/root/soal13_abbey.sh
```

Isi script:

```bash
#!/bin/sh

# Membuat konfigurasi redirect Abbey
cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 80 default_server;
    server_name abbey.k28.com;

    return 302 http://static.k28.com/;
}
EOF

# Mengecek konfigurasi dan reload Nginx
nginx -t && nginx -s reload

echo "=== Soal 13 Abbey selesai ==="
```

Script dibuat executable menggunakan:

```bash
chmod +x /root/soal13_abbey.sh
```


# 4. Hasil Akhir Soal 13

| Server | Akses                           | Status Redirect           | Tujuan                   |
| ------ | ------------------------------- | ------------------------- | ------------------------ |
| Penny  | `192.225.3.3` / `penny.k28.com` | **301 Moved Permanently** | `http://www.k28.com/`    |
| Abbey  | `192.225.4.2` / `abbey.k28.com` | **302 Moved Temporarily** | `http://static.k28.com/` |

---

# 5. Kesimpulan

Pada **Soal 13**, konfigurasi redirect pada server Penny dan Abbey telah berhasil dilakukan.

Server Penny dikonfigurasi menggunakan Apache dengan **HTTP 301 Moved Permanently** menuju `http://www.k28.com/`.

Server Abbey menggunakan Nginx dan dikonfigurasi dengan **HTTP 302 Moved Temporarily** menuju `http://static.k28.com/`.

Berdasarkan hasil pengujian menggunakan `curl`, kedua server telah menghasilkan status HTTP dan alamat redirect sesuai dengan ketentuan soal.

---
# Soal 14 — Access Log IP Asli Client

## Tujuan

Memastikan setiap server web di area **vault** dan **core** mencatat IP asli client yang diteruskan oleh gateway, bukan IP dari Penny atau Abbey.

Node yang digunakan:

* Penny → Gateway Vault
* Abbey → Gateway Core
* Obladi → Server Vault
* Desmond → Server Vault
* Oblada → Server Core
* Molly → Server Core

## 1. Cek konfigurasi Penny

Pada **Penny**, cek konfigurasi `X-Real-IP`.

```bash
grep -R "X-Real-IP" /etc/apache2/
```

Hasil:

```text
/etc/apache2/conf.d/vault-proxy.conf:RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
```

Konfigurasi menunjukkan bahwa Penny meneruskan IP client menggunakan header `X-Real-IP`.

## 2. Cek konfigurasi Abbey

Pada **Abbey**, cek konfigurasi `X-Real-IP`.

```bash
grep -R "X-Real-IP" /etc/nginx/
```

Hasil:

```text
/etc/nginx/http.d/default.conf: proxy_set_header X-Real-IP $remote_addr;
```

Konfigurasi menunjukkan bahwa Abbey meneruskan IP client menggunakan header `X-Real-IP`.

## 3. Konfigurasi Access Log Obladi

Obladi menggunakan Nginx.

Buat konfigurasi access log yang membaca `X-Real-IP`.

```bash
cat > /etc/nginx/http.d/realip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOF
```

Cek konfigurasi:

```bash
nginx -t
```

Jika berhasil:

```text
syntax is ok
test is successful
```

Reload Nginx:

```bash
nginx -s reload
```

Cek port 80:

```bash
ss -ltnp | grep ':80'
```

Hasil menunjukkan Nginx aktif pada port 80.

Cek access log:

```bash
tail -n 1 /var/log/nginx/access.log
```

## 4. Konfigurasi Access Log Desmond

Desmond menggunakan Nginx.

Buat konfigurasi:

```bash
cat > /etc/nginx/http.d/realip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOF
```

Cek:

```bash
nginx -t
```

Jika berhasil:

```text
syntax is ok
test is successful
```

Reload:

```bash
nginx -s reload
```

Cek port 80:

```bash
ss -ltnp | grep ':80'
```

Cek access log:

```bash
tail -n 1 /var/log/nginx/access.log
```

## 5. Konfigurasi Access Log Oblada

Pada Oblada digunakan Nginx.

Buat konfigurasi:

```bash
cat > /etc/nginx/http.d/realip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOF
```

Cek:

```bash
nginx -t
```

Reload:

```bash
nginx -s reload
```

Cek port:

```bash
ss -ltnp | grep ':80'
```

Cek access log:

```bash
tail -n 1 /var/log/nginx/access.log
```

## 6. Konfigurasi Access Log Molly

Pada Molly digunakan Nginx.

Buat konfigurasi:

```bash
cat > /etc/nginx/http.d/realip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOF
```

Cek:

```bash
nginx -t
```

Reload:

```bash
nginx -s reload
```

Cek port:

```bash
ss -ltnp | grep ':80'
```

Cek access log:

```bash
tail -n 1 /var/log/nginx/access.log
```

## 7. Pengujian IP Client

Untuk menguji apakah access log membaca header `X-Real-IP`, dilakukan request dengan IP client.

```bash
curl -H "X-Real-IP: IP_CLIENT" http://127.0.0.1/
```

Kemudian cek:

```bash
tail -n 1 /var/log/nginx/access.log
```

IP yang muncul pada bagian awal access log merupakan IP yang diterima dari header `X-Real-IP`.

**Catatan:** `IP_CLIENT` diganti dengan IP client yang sebenarnya saat pengujian.

## 8. Pengecekan Port Web Server

Pengecekan dilakukan pada seluruh server backend.

### Obladi

```bash
ss -ltnp | grep ':80'
```

### Desmond

```bash
ss -ltnp | grep ':80'
```

### Oblada

```bash
ss -ltnp | grep ':80'
```

### Molly

```bash
ss -ltnp | grep ':80'
```

Hasil menunjukkan bahwa Nginx aktif dan listening pada port 80 di seluruh server backend.

***Screenshot hasil `ss` dari Obladi, Desmond, Oblada, dan Molly:****

<img width="959" height="505" alt="Screenshot 2026-10-01 002304" src="https://github.com/user-attachments/assets/ec078a1b-35f2-4c26-a818-96a217ce3e66" />

## Kesimpulan

Konfigurasi access log pada server web area **vault** dan **core** telah berhasil dilakukan. Penny dan Abbey meneruskan IP asli client menggunakan header `X-Real-IP`. Server backend kemudian dikonfigurasi agar access log membaca header tersebut. Dengan konfigurasi ini, access log mencatat **IP asli client**, bukan IP dari Penny atau Abbey.

# Versi Otomatis (Script)

## 1. Cek Penny

Pada **Penny**:

```bash
grep -R "X-Real-IP" /etc/apache2/
```

## 2. Cek Abbey

Pada **Abbey**:

```bash
grep -R "X-Real-IP" /etc/nginx/
```

# 3. Script Soal 14

Script dijalankan pada **Obladi, Desmond, Oblada, dan Molly** karena keempat server menggunakan Nginx.

Isi script:

```bash
cat > /root/soal14.sh <<'EOF'
#!/bin/sh

echo "=== SOAL 14 - ACCESS LOG ==="

cat > /etc/nginx/http.d/realip-log.conf <<'EOL'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
access_log /var/log/nginx/access.log realip;
EOL

echo "[1] Cek konfigurasi Nginx..."
nginx -t || exit 1

echo "[2] Reload Nginx..."
nginx -s reload

echo "[3] Cek port 80..."
ss -ltnp | grep ':80'

echo "[4] Access log terakhir..."
tail -n 1 /var/log/nginx/access.log

echo "=== SOAL 14 SELESAI ==="
EOF
```

Kemudian beri izin:

```bash
chmod +x /root/soal14.sh 
```

Jalankan:

```bash
/root/soal14.sh
```


## 4. Obladi

Script dijalankan pada **Obladi**.

```bash
/root/soal14.sh
```

Script melakukan:

* membuat konfigurasi `X-Real-IP`
* mengecek Nginx
* reload Nginx
* mengecek port 80
* menampilkan access log terakhir

## 5. Desmond

Pada **Desmond**:

```bash
/root/soal14.sh
```

## 6. Oblada

Pada **Oblada**:

```bash
/root/soal14.sh
```

## 7. Molly

Pada **Molly**:

```bash
/root/soal14.sh
```

# Soal 15 — Reverse Proxy Path Khusus

## Tujuan

Membuat dua jalur proxy khusus:

* **Penny:** `/eternal` → `/var/www/eternal` dengan PHP rendering.
* **Abbey:** `/orion` → `/var/www/orion` secara static tanpa PHP rendering.

---

# A. Penny — `/eternal`

## Step Manual

### 1. Install PHP 8.4 dan PHP-FPM

Pada `penny`:

```bash
apk add php84 php84-fpm
```

Cek versi PHP:

```bash
php84 -v
```

### 2. Jalankan PHP-FPM

```bash
php-fpm84 -D
```

Cek PHP-FPM:

```bash
ss -ltnp | grep 9000
```

PHP-FPM harus terlihat berjalan pada `127.0.0.1:9000`.
<img width="775" height="192" alt="Screenshot 2026-10-01 010939" src="https://github.com/user-attachments/assets/1031f3cb-1d53-4c2b-8a4f-aff2c50a7ffa" />

> Ambil screenshot saat hasil `ss -ltnp | grep 9000` terlihat.

---

### 3. Buat directory `/var/www/eternal`

```bash
mkdir -p /var/www/eternal
```

Buat file PHP:

```bash
cat > /var/www/eternal/index.php <<'EOF'
<?php echo "Eternal PHP OK"; ?>
EOF
```

---

### 4. Konfigurasi Apache

Buat:

```text
/etc/apache2/conf.d/eternal.conf
```

Isi:

```apache
ProxyPass "/eternal" "!"

Alias /eternal/ /var/www/eternal/

<Directory "/var/www/eternal">
    Options Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
```

Cek konfigurasi:

```bash
httpd -t
```

Jika hasilnya:

```text
Syntax OK
```

restart Apache:

```bash
httpd -k restart
```

---

### 5. Test `/eternal`

```bash
curl -i http://127.0.0.1/eternal/
```

Hasil yang diharapkan:

```text
HTTP/1.1 200 OK
X-Powered-By: PHP/8.4.21

Eternal PHP OK
```

<img width="570" height="247" alt="Screenshot 2026-10-01 010921" src="https://github.com/user-attachments/assets/14d6da72-71bf-4273-bb3d-31d5c7c2a7c8" />


> Ambil screenshot hasil `curl` yang memperlihatkan `200 OK`, `X-Powered-By: PHP/8.4.21`, dan `Eternal PHP OK`.

---

## Script Penny

Script disimpan di:

```text
/root/soal15_penny.sh
```

```bash
#!/bin/sh

apk add php84 php84-fpm

php-fpm84 -D

mkdir -p /var/www/eternal

cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "Eternal PHP OK";
?>
PHP

cat > /etc/apache2/conf.d/eternal.conf <<'APACHE'
ProxyPass "/eternal" "!"

Alias /eternal/ /var/www/eternal/

<Directory "/var/www/eternal">
    Options Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
APACHE

httpd -t && httpd -k restart

echo "=== Soal 15 Penny selesai ==="
```

---

# B. Abbey — `/orion`

## Step Manual

### 1. Buat directory `/var/www/orion`

Pada `abbey`:

```bash
mkdir -p /var/www/orion
```

Buat halaman static:

```bash
cat > /var/www/orion/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body>
<h1>Orion Static OK</h1>
<p>This is a static page.</p>
</body>
</html>
EOF
```

---

### 2. Konfigurasi Nginx

Edit:

```text
/etc/nginx/http.d/default.conf
```

Pada `server` `abbey.k28.com`, gunakan:

```nginx
server {
    listen 80 default_server;
    server_name abbey.k28.com;

    location = /orion {
        return 301 /orion/;
    }

    location ~ ^/orion/.*\.php$ {
        return 404;
    }

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        return 302 http://static.k28.com/;
    }
}
```

Cek konfigurasi:

```bash
nginx -t
```

Hasil harus:

```text
syntax is ok
test is successful
```

<img width="742" height="248" alt="Screenshot 2026-10-01 011002" src="https://github.com/user-attachments/assets/64e77846-0b70-4797-8d9f-76775dc70159" />


> Ambil screenshot tepat setelah `nginx -t` berhasil.

Kemudian reload:

```bash
nginx -s reload
```

---

### 3. Test `/orion`

```bash
curl -i -H 'Host: abbey.k28.com' http://127.0.0.1/orion/
```

Hasil yang diharapkan:

```text
HTTP/1.1 200 OK

Orion Static OK
```

<img width="739" height="518" alt="Screenshot 2026-10-01 011014" src="https://github.com/user-attachments/assets/d6e2be0f-40eb-4091-90f3-d069f9091ba2" />


> Ambil screenshot hasil `curl` yang memperlihatkan `200 OK` dan `Orion Static OK`.

---

## Script Abbey

Script disimpan di:

```text
/root/soal15_abbey.sh
```

```bash
#!/bin/sh

mkdir -p /var/www/orion

cat > /var/www/orion/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body>
<h1>Orion Static OK</h1>
<p>This is a static page.</p>
</body>
</html>
HTML

cat > /etc/nginx/http.d/default.conf <<'NGINX'
upstream core_backend {
    server 192.225.5.6;
    server 192.225.5.7;
}

server {
    listen 80;
    server_name core.k28.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 80 default_server;
    server_name abbey.k28.com;

    location = /orion {
        return 301 /orion/;
    }

    location ~ ^/orion/.*\.php$ {
        return 404;
    }

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }

    location / {
        return 302 http://static.k28.com/;
    }
}
NGINX

nginx -t && nginx -s reload

echo "=== Soal 15 Abbey selesai ==="
```

Permission:

```bash
chmod +x /root/soal15_abbey.sh
```

---

# C. Hasil Akhir

| Node  | Path        | Directory           | Mode          |
| ----- | ----------- | ------------------- | ------------- |
| Penny | `/eternal/` | `/var/www/eternal/` | PHP + PHP-FPM |
| Abbey | `/orion/`   | `/var/www/orion/`   | Static        |

# SOAL 16 — Stress Test ApacheBench

## 1. Tujuan

Melakukan stress test terhadap dua endpoint menggunakan **ApacheBench (AB)** dari client `Alpha` dengan ketentuan:

* Total requests: **250**
* Concurrency: **10**
* Endpoint pertama: `http://www.k28.com/`
* Endpoint kedua: `http://static.k28.com/`

---

# 2. Step Manual

## 2.1 Menyiapkan ApacheBench pada Alpha

Masuk ke console `Alpha` dan periksa apakah ApacheBench tersedia:

```bash
ab -V
```

Pada awalnya ApacheBench belum tersedia, sehingga dilakukan instalasi:

```bash
apk add apache2-utils
```

Setelah instalasi selesai, ApacheBench diperiksa kembali:

```bash
ab -V
```

Hasil:

```text
This is ApacheBench, Version 2.3
```

ApacheBench berhasil terpasang dan siap digunakan.

---

## 2.2 Benchmark `www.k28.com`

Pengujian dilakukan dengan **250 requests** dan **concurrency 10**:

```bash
ab -n 250 -c 10 http://www.k28.com/
```

ApacheBench menyelesaikan seluruh 250 requests.

Hasil utama:

```text
Concurrency Level:      10
Time taken for tests:   4.972 seconds
Complete requests:      250
Failed requests:        0
Non-2xx responses:      250
Requests per second:    50.29 [#/sec] (mean)
Time per request:       198.865 [ms] (mean)
Transfer rate:          347.68 [Kbytes/sec] received
```

<img width="837" height="963" alt="Screenshot 2026-10-01 012809" src="https://github.com/user-attachments/assets/4e07b950-c95f-4e52-a052-7de5712ba56d" />

---

## 2.3 Benchmark `static.k28.com`

Pengujian berikutnya dilakukan terhadap endpoint `static.k28.com` dengan parameter yang sama:

```bash
ab -n 250 -c 10 http://static.k28.com/
```

ApacheBench juga menyelesaikan seluruh 250 requests.

Hasil utama:

```text
Concurrency Level:      10
Time taken for tests:   4.812 seconds
Complete requests:      250
Failed requests:        0
Non-2xx responses:      250
Requests per second:    51.95 [#/sec] (mean)
Time per request:       192.480 [ms] (mean)
Transfer rate:          359.36 [Kbytes/sec] received
```

<img width="1324" height="1052" alt="image" src="https://github.com/user-attachments/assets/2cdd0ab6-cff9-4cef-b25a-fbf55b39cea5" />

---

# 3. Rangkuman Hasil

| Parameter           | `www.k28.com` | `static.k28.com` |
| ------------------- | ------------: | ---------------: |
| Requests            |           250 |              250 |
| Concurrency         |            10 |               10 |
| Complete requests   |           250 |              250 |
| Failed requests     |             0 |                0 |
| Non-2xx responses   |           250 |              250 |
| Time taken          |       4.972 s |          4.812 s |
| Requests per second |   50.29 req/s |      51.95 req/s |
| Time per request    |    198.865 ms |       192.480 ms |
| Transfer rate       |   347.68 KB/s |      359.36 KB/s |
| Longest request     |        361 ms |           201 ms |

Pada kedua pengujian, ApacheBench menyelesaikan seluruh **250 requests** dengan tingkat konkurensi **10** dan mencatat **0 failed requests**.

Nilai `Non-2xx responses: 250` menunjukkan bahwa response HTTP yang diterima bukan status 2xx. Hal ini sesuai dengan kondisi konfigurasi endpoint yang masih menghasilkan response redirect.

---

# 4. Script

Script Soal 16 disimpan pada:

```text
/root/soal16.sh
```

Isi script:

```bash
#!/bin/sh

echo "=== ApacheBench: www.k28.com ==="
ab -n 250 -c 10 http://www.k28.com/

echo ""
echo "=== ApacheBench: static.k28.com ==="
ab -n 250 -c 10 http://static.k28.com/

echo ""
echo "=== Soal 16 selesai ==="
```

Permission executable diberikan menggunakan:

```bash
chmod +x /root/soal16.sh
```

Script tersebut digunakan untuk menjalankan benchmark ApacheBench terhadap kedua endpoint dengan konfigurasi **250 requests** dan **concurrency 10**.

# Soal 17 — TXT Record DNS

## 1. Tujuan

Menambahkan **TXT record** pada DNS master `prab` untuk seluruh klien sayap kiri dan sayap kanan, yaitu:

* `alpha.k28.com` → `"alpha"`
* `beta.k28.com` → `"beta"`
* `gamma.k28.com` → `"gamma"`
* `delta.k28.com` → `"delta"`
* `epsilon.k28.com` → `"epsilon"`

DNS master yang digunakan adalah `prab` dengan alamat IP `192.225.5.2`.

---

## 2. Step Manual

### 2.1 Mengecek konfigurasi DNS

Pada server `prab`, konfigurasi zone `k28.com` terdapat pada:

```text
/etc/bind/named.conf
```

Zone menggunakan file:

```text
/var/bind/k28.com
```

Konfigurasi zone:

```text
zone "k28.com" IN {
    type master;
    file "/var/bind/k28.com";
    notify yes;
    also-notify { 192.225.5.3; };
    allow-transfer { 192.225.5.3; };
};
```

---

### 2.2 Menambahkan TXT record

File zone `/var/bind/k28.com` kemudian ditambahkan lima TXT record:

```text
alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
```

Serial SOA juga dinaikkan dari:

```text
1790762977
```

menjadi:

```text
1790762978
```

---

### 2.3 Validasi zone

Setelah perubahan, konfigurasi zone diperiksa menggunakan:

```bash
named-checkzone k28.com /var/bind/k28.com
```

Hasil validasi:

```text
zone k28.com/IN: loaded serial 1790762978
OK
```

<img width="731" height="283" alt="image" src="https://github.com/user-attachments/assets/68592466-cd29-4ac1-a5c7-b7e26ab48fad" />


---

### 2.4 Menjalankan DNS Server

Pada saat pengecekan, proses `named` tidak sedang berjalan sehingga DNS belum dapat menerima query.

BIND kemudian dijalankan menggunakan:

```bash
named -c /etc/bind/named.conf
```

Proses diverifikasi menggunakan:

```bash
ps aux | grep '[n]amed'
```

Hasil menunjukkan proses BIND aktif:

```text
root  112  ... named -c /etc/bind/named.conf
```

---

### 2.5 Pengujian TXT record

Query TXT dilakukan terhadap DNS master `prab`:

```bash
dig @192.225.5.2 alpha.k28.com TXT +short
```

Hasil:

```text
"alpha"
```


<img width="479" height="170" alt="image" src="https://github.com/user-attachments/assets/1a8bc5a4-6e8b-49e9-b245-161e0a0b19af" />


---

### 2.6 Pengujian seluruh hostname

Selanjutnya seluruh record TXT diuji sekaligus:

```bash
for h in beta gamma delta epsilon; do
    echo "$h:"
    dig @192.225.5.2 "$h.k28.com" TXT +short
done
```

Hasil:

```text
beta:
"beta"

gamma:
"gamma"

delta:
"delta"

epsilon:
"epsilon"
```

Dengan hasil tersebut, seluruh TXT record telah dapat di-query melalui DNS master `prab`.

<img width="537" height="287" alt="image" src="https://github.com/user-attachments/assets/88495282-d362-4969-818d-d818ee50247f" />


---

## 3. Hasil

| Hostname          | TXT Record  | Status   |
| ----------------- | ----------- | -------- |
| `alpha.k28.com`   | `"alpha"`   | Berhasil |
| `beta.k28.com`    | `"beta"`    | Berhasil |
| `gamma.k28.com`   | `"gamma"`   | Berhasil |
| `delta.k28.com`   | `"delta"`   | Berhasil |
| `epsilon.k28.com` | `"epsilon"` | Berhasil |

Seluruh hostname klien sayap kiri dan sayap kanan telah memiliki TXT record yang mengembalikan nama hostname masing-masing ketika dilakukan query DNS.

---

## 4. Script

Script konfigurasi dibuat pada:

```text
/root/soal17.sh
```

Isi script:

```sh
#!/bin/sh

ZONE="/var/bind/k28.com"

# Update serial SOA
sed -i 's/1790762978/1790762979/' "$ZONE"

# Tambahkan TXT record jika belum ada
grep -q '^alpha[[:space:]].*TXT' "$ZONE" || cat >> "$ZONE" <<'EOF'

alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF

# Validasi zone
named-checkzone k28.com "$ZONE"

# Jalankan BIND jika belum aktif
if ! pgrep -x named >/dev/null 2>&1; then
    named -c /etc/bind/named.conf
else
    kill -HUP "$(pgrep -xo named)"
fi

echo "=== Soal 17 selesai ==="
```

Permission script:

```bash
chmod +x /root/soal17.sh
```
## Soal 18 — Perubahan A Record, TTL, dan Sinkronisasi DNS

### Step Manual

#### 1. Cek kondisi awal A record Abbey

Pada node **prab**, dilakukan pengecekan A record `abbey.k28.com` sebelum perubahan.

```bash
dig @192.225.5.2 abbey.k28.com A +noall +answer
```

Hasil awal menunjukkan IP Abbey:

```text
abbey.k28.com.    604800    IN    A    192.225.4.2
```

<img width="588" height="122" alt="Screenshot 2026-10-01 015826" src="https://github.com/user-attachments/assets/0be1e295-8663-4d5b-8104-411d0107ecc2" />

> Tampilkan hasil `dig` yang menunjukkan A record lama `192.225.4.2`.

---

#### 2. Periksa serial SOA sebelum perubahan

Pada **prab**, nilai serial SOA sebelum perubahan adalah:

```bash
dig @192.225.5.2 k28.com SOA +short
```

Serial awal:

```text
1790762978
```

Nilai ini digunakan sebagai dasar sebelum melakukan perubahan record.

---

#### 3. Ubah A record Abbey dan TTL

File zone pada **prab**:

```bash
vi /var/bind/k28.com
```

Record Abbey diubah dari:

```text
abbey   IN  A   192.225.4.2
```

menjadi:

```text
abbey   15  IN  A   10.99.99.99
```

IP `10.99.99.99` digunakan sebagai IP fiktif yang tetap memiliki format IPv4 valid.

Serial SOA dinaikkan dari:

```text
1790762978
```

menjadi:

```text
1790762979
```

---

#### 4. Validasi zone

Setelah perubahan dilakukan, zone diperiksa menggunakan:

```bash
named-checkzone k28.com /var/bind/k28.com
```

Hasil:

```text
zone k28.com/IN: loaded serial 1790762979
OK
```

<img width="731" height="283" alt="Screenshot 2026-10-01 014631" src="https://github.com/user-attachments/assets/6f3eb51c-05f4-4166-bfdd-ec0153d1d310" />

> Tampilkan hasil `named-checkzone` dengan status `OK` dan serial `1790762979`.

---

#### 5. Reload DNS Master

Agar perubahan zone dimuat oleh BIND, dilakukan reload terhadap proses `named`:

```bash
kill -HUP "$(pgrep -xo named)"
```

Kemudian record diperiksa kembali:

```bash
dig @192.225.5.2 abbey.k28.com A +noall +answer
```

Hasil:

```text
abbey.k28.com.    15    IN    A    10.99.99.99
```

Hasil tersebut menunjukkan bahwa A record baru telah aktif dan TTL record Abbey telah ditetapkan menjadi **15 detik**.

<img width="556" height="93" alt="image" src="https://github.com/user-attachments/assets/0f64f1ae-19dc-4942-a4ad-8d86747d377b" />

> Tampilkan hasil `dig` yang menunjukkan `10.99.99.99` dengan TTL `15`.

---

#### 6. Verifikasi sinkronisasi ke tedd

Slave DNS pada **tedd** diperiksa menggunakan:

```bash
dig @192.225.5.3 k28.com SOA +short
```

Serial yang diperoleh:

```text
1790762979
```

Kemudian A record Abbey diperiksa:

```bash
dig @192.225.5.3 abbey.k28.com A +noall +answer
```

Hasil:

```text
abbey.k28.com.    15    IN    A    10.99.99.99
```

Serial pada `prab` dan `tedd` telah sama sehingga zone berhasil tersinkronisasi.

<img width="544" height="82" alt="image" src="https://github.com/user-attachments/assets/ea080b38-85d1-439d-a0ce-e46dc0471fcc" />

> Tampilkan serial `1790762979` pada tedd dan A record Abbey `10.99.99.99` dengan TTL `15`.

---

### Verifikasi Tiga Fase TTL

Sesuai instruksi soal, perubahan DNS seharusnya diamati melalui tiga fase:

1. **Sebelum perubahan**
   Query mengembalikan IP lama:

   ```text
   192.225.4.2
   ```

2. **Sesaat setelah perubahan, sebelum TTL 15 detik habis**
   Resolver caching seharusnya masih mengembalikan IP lama karena jawaban sebelumnya masih berada di cache.

3. **Setelah TTL 15 detik habis**
   Resolver melakukan query ulang dan mendapatkan IP baru:

   ```text
   10.99.99.99
   ```

Pada environment praktikum yang digunakan, node yang tersedia tidak menjalankan caching DNS resolver (`named`, `dnsmasq`, `unbound`, `nscd`, atau `systemd-resolved`). Query langsung ke `prab` dan `tedd` merupakan query ke authoritative DNS sehingga tidak dapat digunakan untuk membuktikan fase kedua berupa cache yang masih menyimpan IP lama.

Oleh karena itu, fase cache tidak dibuat-buat dalam laporan. Bukti yang berhasil diverifikasi secara langsung adalah kondisi sebelum perubahan, perubahan record dengan TTL 15 detik, validasi zone, serta sinkronisasi master-slave.

---

## Script

Script verifikasi disimpan pada:

```text
/root/soal18.sh
```

Isi script:

```sh
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
```

Script diberikan permission executable:

```bash
chmod +x /root/soal18.sh
```

Script dijalankan pada node **prab**:

```bash
/root/soal18.sh
```

Script digunakan untuk memverifikasi serial SOA pada master dan slave, A record Abbey, TTL record, serta validitas zone.

# Soal 19 — CNAME `outbound.k28.com` ke `http.badssl.com`

## Tujuan

Membuat CNAME record yang mengarahkan domain internal `outbound.k28.com` menuju domain eksternal `http.badssl.com`, kemudian melakukan pengujian menggunakan `curl`.

---

## Step Manual

### 1. Menambahkan CNAME Record

Pada server **prab**, edit zone file:

```sh
vi /var/bind/k28.com
```

Tambahkan record:

```text
outbound    IN    CNAME    http.badssl.com.
```

Serial SOA dinaikkan menjadi:

```text
1790762980
```

---

### 2. Validasi Zone

Jalankan:

```sh
named-checkzone k28.com /var/bind/k28.com
```

Hasil:

```text
zone k28.com/IN: loaded serial 1790762980
OK
```

<img width="600" height="317" alt="Screenshot 2026-10-01 022037" src="https://github.com/user-attachments/assets/28428e8b-2006-4c0a-80ed-df72f4a56c45" />


---

### 3. Reload BIND

Setelah zone valid, reload service BIND pada `prab`:

```sh
kill -HUP "$(pgrep -xo named)"
```

---

### 4. Verifikasi CNAME

Periksa record CNAME melalui DNS server `prab`:

```sh
dig @192.225.5.2 outbound.k28.com CNAME +noall +answer
```

Hasil:

```text
outbound.k28.com.       604800  IN  CNAME  http.badssl.com.
```

Hal ini menunjukkan bahwa `outbound.k28.com` telah memiliki CNAME menuju `http.badssl.com`.

<img width="660" height="245" alt="Screenshot 2026-10-01 022047" src="https://github.com/user-attachments/assets/fc2de331-59cc-45e2-b14e-6b0cc74f71c9" />


---

### 5. Pengujian Domain Tujuan

Untuk memastikan domain tujuan dapat diakses:

```sh
curl -I http://http.badssl.com
```

Hasil:

```text
HTTP/1.1 200 OK
Server: nginx/1.10.3 (Ubuntu)
Content-Type: text/html
```

<img width="480" height="314" alt="Screenshot 2026-10-01 022058" src="https://github.com/user-attachments/assets/dedd768f-9cf9-4504-a29f-30af04483d4d" />


---

### 6. Pengujian Melalui CNAME

Lakukan request melalui domain internal dengan Host header tujuan:

```sh
curl -H "Host: http.badssl.com" http://outbound.k28.com
```

Hasil konten kemudian dibandingkan dengan konten dari domain asli.

---

### 7. Membandingkan Konten

Simpan konten dari domain asli:

```sh
curl -s http://http.badssl.com > /tmp/asli
```

Simpan konten dari domain CNAME:

```sh
curl -s -H "Host: http.badssl.com" http://outbound.k28.com > /tmp/cname
```

Kemudian bandingkan:

```sh
diff -u /tmp/asli /tmp/cname
```

Tidak terdapat output dari perintah `diff`, sehingga tidak ditemukan perbedaan antara kedua konten.

**Screenshot 4 — Perbandingan konten**

<img width="675" height="101" alt="Screenshot 2026-10-01 022253" src="https://github.com/user-attachments/assets/af8c218d-ad13-40f5-b18d-00699877b634" />


---

## Script

Script konfigurasi dan verifikasi disimpan pada:

```text
/root/soal19.sh
```

Isi script:

```sh
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
```

### Kesimpulan

CNAME `outbound.k28.com` berhasil dibuat dan ter-resolve menuju `http.badssl.com`. Pengujian menggunakan `curl` dengan Host tujuan menunjukkan konten yang identik dengan `http.badssl.com`, dibuktikan dengan perintah `diff` yang tidak menghasilkan perbedaan.






