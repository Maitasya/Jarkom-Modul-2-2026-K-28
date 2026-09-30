# Jarkom-Modul-2-2026-K-28

## Kelompok K-28

|            Nama           |     NRP    |
| :-----------------------: | :--------: |
|   Maitasya Rohmatul Ula   | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

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

<!-- SS: screenshot topologi GNS3 -->
![Topologi](img/soal1-topologi.png)

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

**1. Tulis `/etc/network/interfaces` (contoh obladi)**

```sh
cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.225.5.4
netmask 255.255.255.0
gateway 192.225.5.1
EOF
```

**2. Terapkan IP sekarang tanpa reboot**

```sh
ip addr flush dev eth0
ip addr add 192.225.5.4/24 dev eth0
ip route replace default via 192.225.5.1
```

**3. Verifikasi**

```sh
ip -br addr
ip route
ping -c 3 192.225.5.1
ping -c 3 8.8.8.8
```

<!-- SS: ip -br addr, ip route, dan ping berhasil (satu SS untuk satu node, mis. obladi) -->
![Verifikasi obladi](img/soal1-obladi.png)

Ulangi untuk node lain dengan IP dan gateway sesuai tabel.

**4. Uji wiring dengan tcpdump (di rootkit)**

```sh
tcpdump -ni any arp or icmp
```

Sambil ping ke gateway dari node, pastikan paket masuk lewat interface rootkit yang sesuai tabel topologi.

### Versi Otomatis (Script)

Script `soal1.sh` dibuat di tiap node. Ubah dua baris `IP` dan `GW` sesuai tabel. Contoh di bawah untuk **obladi**:

```sh
cat > /root/soal1.sh <<'EOT'
#!/bin/bash
IP="192.225.5.4"
GW="192.225.5.1"

ip addr flush dev eth0
ip addr add $IP/24 dev eth0
ip route replace default via $GW

cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address $IP
netmask 255.255.255.0
gateway $GW
EOF

echo "=== IP ADDRESS ==="
ip -br addr
echo "=== ROUTING ==="
ip route
EOT
chmod +x /root/soal1.sh
/root/soal1.sh
```

Nilai `IP` dan `GW` untuk node yang berubah:

| Node | IP | GW |
|------|----|----|
| abbey | 192.225.4.2 | 192.225.4.1 |
| penny | 192.225.3.3 | 192.225.3.1 |
| obladi | 192.225.5.4 | 192.225.5.1 |
| desmond | 192.225.5.5 | 192.225.5.1 |
| oblada | 192.225.5.6 | 192.225.5.1 |
| molly | 192.225.5.7 | 192.225.5.1 |

Script verifikasi `cek_node*.sh` di README sebelumnya tetap dipakai sebagai pengecekan tambahan.

---

# Soal 2 — Konfigurasi NAT dan Akses Internet

## Tujuan

Mengaktifkan *IP forwarding* dan konfigurasi NAT pada `rootkit` agar seluruh jaringan internal dapat meneruskan lalu lintas menuju internet melalui interface WAN `eth0`.

### Konfigurasi Rootkit

Pada node **`rootkit`**, konfigurasi `/etc/network/interfaces` ditambahkan:

```text
up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
up iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

Konfigurasi tersebut mengaktifkan *IP forwarding*, melakukan *MASQUERADE* untuk jaringan internal, serta mengizinkan lalu lintas dari seluruh interface internal `eth1`–`eth5` menuju interface WAN `eth0`.

## Verifikasi

Pengujian dilakukan pada **console masing-masing client/node internal**, bukan hanya pada `rootkit`.

Contoh pada **alpha**:

```bash
ping -c 3 8.8.8.8
```

Kemudian:

```bash
ping -c 3 google.com
```

<img width="410" height="179" alt="image" src="https://github.com/user-attachments/assets/a74ae3e5-43d8-4cae-a905-97583a53a178" />


Pengujian yang sama dapat dilakukan pada node internal lainnya untuk memastikan seluruh jaringan dapat mengakses internet. Hasil pengujian menunjukkan bahwa node internal dapat menjangkau alamat IP publik `8.8.8.8` dan melakukan koneksi menggunakan nama domain `google.com`.  Ketika pengujian `ping google.com` mengalami kegagalan, dilakukan pengecekan konfigurasi DNS pada node yang bermasalah menggunakan:

```bash
cat /etc/resolv.conf
```

Jika konfigurasi DNS belum sesuai, file `/etc/resolv.conf` diperbaiki menggunakan:

```bash
nano /etc/resolv.conf
```

Kemudian ditambahkan nameserver:

```text
nameserver 8.8.8.8
nameserver 1.1.1.1
```

Setelah konfigurasi DNS diperbaiki, dilakukan pengujian kembali menggunakan:

```bash
ping -c 3 google.com
```

Hasil pengujian digunakan untuk memastikan node dapat melakukan resolusi nama domain dan terhubung ke internet.

---
# Soal 3 — Routing Internal dan Resolver

## Tujuan

Memastikan seluruh Entitas dapat saling berkomunikasi melalui `rootkit` sebagai router serta memastikan setiap host non-router memiliki resolver `192.168.122.1` untuk mendukung akses jaringan dan instalasi paket.

### Mengaktifkan Routing pada Rootkit

Pada **console `rootkit`**, aktifkan IP forwarding:

```bash
sysctl -w net.ipv4.ip_forward=1
```

Kemudian cek:

```bash
sysctl net.ipv4.ip_forward
```

Nilai yang diperoleh harus:

```text
net.ipv4.ip_forward = 1
```

### Menambahkan Resolver pada Host Non-Router

Pada setiap **host selain `rootkit`**, cek konfigurasi DNS:

```bash
cat /etc/resolv.conf
```

Jika belum terdapat resolver `192.168.122.1`, edit file:

```bash
nano /etc/resolv.conf
```

Tambahkan:

```text
nameserver 192.168.122.1
```

Jika resolver tersebut sudah tersedia, tidak perlu menambahkan resolver lain.

### Pengujian Routing Internal

Pengujian dilakukan dari host non-router dengan melakukan ping ke gateway dan host pada jaringan lain.

Contoh dari **alpha**:

```bash
ping -c 3 192.225.1.1
```

Kemudian menguji komunikasi lintas jaringan, misalnya:

```bash
ping -c 3 192.225.5.2
```

Jika berhasil, berarti paket dapat melewati `rootkit` menuju jaringan internal lainnya.

###  Pengujian DNS

Pada host non-router, dilakukan pengujian resolusi nama domain:

```bash
ping -c 3 google.com
```

Pengujian ini memastikan resolver dapat menerjemahkan nama domain menjadi alamat IP.

---
## Soal 4: DNS Master-Slave dan Resolver (K28)

### Ringkasan

| Node | Peran | IP |
|------|-------|----|
| prab | DNS master (ns1) | 192.225.5.2 |
| tedd | DNS slave (ns2) | 192.225.5.3 |
| penny | Gerbang aplikasi dinamis (A record apex) | 192.225.3.3 |

Tujuan:
- prab menjadi master authoritative untuk zona `k28.com` (SOA, NS, A record, notify, allow-transfer, forwarders `192.168.122.1`).
- tedd menarik zona dari prab dan menjawab secara authoritative.
- Semua node non-router memakai urutan resolver: prab, tedd, `192.168.122.1`.

### Langkah Pengerjaan

**1. Persiapan (prab dan tedd)**

```sh
cat /etc/resolv.conf
ping -c 2 google.com
ping -c 2 192.225.5.3   # dari prab
ping -c 2 192.225.5.2   # dari tedd
apk update
apk add bind bind-tools
```

**2. Konfigurasi prab (master)**

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

<!-- SS: named-checkzone OK, serial 1790000001 -->
![Checkzone prab](img/soal4-checkzone.png)

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
![Verifikasi prab 1](img/soal4-prab1.png)
![Verifikasi prab 2](img/soal4-prab2.png)

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
dig @192.225.5.3 k28.com
dig @192.225.5.2 k28.com SOA +short
dig @192.225.5.3 k28.com SOA +short
```

Hasil yang benar: file `k28.com` ada di `/var/bind/slave/`, flags `qr aa`, jawaban `192.225.3.3`, dan serial prab dan tedd sama (`1790000001`).

<!-- SS: ls slave, dig @tedd k28.com, dan dua SOA -->
![Verifikasi tedd 1](img/soal4-tedd1.png)
![Verifikasi tedd 2](img/soal4-tedd2.png)

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

<!-- SS: resolv.conf dan hasil dig di salah satu node -->
![Verifikasi resolver](img/soal4-resolver.png)

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
echo "=== Selesai ==="
EOT
chmod +x /root/soal4_prab.sh
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
echo "=== Selesai ==="
EOT
chmod +x /root/soal4_tedd.sh
```

Urutan: `soal4_prab.sh` di prab, lalu `soal4_tedd.sh` di tedd (tunggu 5 sampai 10 detik), lalu `resolver_soal4.sh` di semua node non-router.

---
## Soal 5: A Record Semua Entitas

### Tujuan
Menambahkan A record semua entitas ke zona `k28.com` di prab, lalu memastikan tedd menarik zona terbaru.

### Tabel Record

| Hostname | IP |
|----------|----|
| rootkit | 192.225.5.1 |
| alpha | 192.225.1.2 |
| beta | 192.225.1.3 |
| gamma | 192.225.1.4 |
| delta | 192.225.2.2 |
| epsilon | 192.225.2.3 |
| abbey | 192.225.4.2 |
| penny | 192.225.3.3 |
| obladi | 192.225.5.4 |
| desmond | 192.225.5.5 |
| oblada | 192.225.5.6 |
| molly | 192.225.5.7 |

`prab`, `tedd`, dan apex `k28.com` sudah ada dari soal 4.

### Langkah Pengerjaan (Step by Step)

**1. Cek zona sebelum diubah (prab)**

```sh
cat /var/bind/k28.com
```

**2. Tambahkan record (prab)**

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

**3. Naikkan serial supaya tedd menarik zona baru (prab)**

```sh
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" /var/bind/k28.com
```

**4. Cek zona lalu muat ulang named (prab)**

```sh
named-checkzone k28.com /var/bind/k28.com
pkill named
sleep 1
named -u named
```

<!-- SS: named-checkzone OK dan serial baru -->
![Checkzone soal 5](img/soal5-checkzone.png)

**5. Tes semua nama (prab)**

```sh
for h in rootkit alpha beta gamma delta epsilon prab tedd abbey penny obladi desmond oblada molly; do
    echo -n "$h: "; dig @192.225.5.2 $h.k28.com +short
done
dig @192.225.5.2 k28.com +short
```

<!-- SS: hasil 14 nama dan apex (192.225.3.3) -->
![Tes DNS prab](img/soal5-dig.png)

**6. Cek sinkronisasi di tedd**

```sh
dig @192.225.5.3 k28.com SOA +short
dig @192.225.5.3 abbey.k28.com +short
dig @192.225.5.3 molly.k28.com +short
```

Serial harus sama dengan prab. Kalau tedd masih menjawab data lama, hapus salinan lama:

```sh
pkill named
rm -f /var/bind/slave/k28.com
named -u named
sleep 4
```

<!-- SS: serial sama dan jawaban dari tedd -->
![Sinkronisasi tedd](img/soal5-tedd.png)

### Versi Otomatis (Script)

```sh
cat > /root/soal5_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 5: A record semua entitas ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

# Hapus record lama supaya tidak dobel kalau script dijalankan ulang
for h in rootkit alpha beta gamma delta epsilon abbey penny obladi desmond oblada molly; do
    sed -i "/^$h[[:space:]]/d" $ZONA
done

cat >> $ZONA <<'EOF'
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

# Naikkan serial supaya tedd menarik zona baru
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" $ZONA

echo "=== Cek zona ==="
named-checkzone k28.com $ZONA || exit 1

echo "=== Muat ulang named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "=== Tes DNS ==="
for h in rootkit alpha beta gamma delta epsilon prab tedd abbey penny obladi desmond oblada molly; do
    echo -n "$h: "
    dig @192.225.5.2 $h.k28.com +short
done
echo -n "k28.com (apex): "
dig @192.225.5.2 k28.com +short
echo "=== Selesai ==="
EOT
chmod +x /root/soal5_prab.sh
/root/soal5_prab.sh
```

---


---
## Soal 7: Web Server Statis dan Dinamis pada DNS

### Tujuan
Menambahkan record pada zona `k28.com` untuk mengelompokkan node berdasarkan peran, lalu memverifikasi dari dua klien bahwa hasil resolve konsisten.

### Pembagian Peran

| Node | IP | Peran |
|------|----|-------|
| abbey | 192.225.4.2 | Gerbang utama |
| penny | 192.225.3.3 | Gerbang utama |
| obladi | 192.225.5.4 | Web statis (area vault) |
| desmond | 192.225.5.5 | Web statis (area vault) |
| oblada | 192.225.5.6 | Web dinamis (area core) |
| molly | 192.225.5.7 | Web dinamis (area core) |

### Record yang Ditambahkan

| Nama | Tipe | Tujuan |
|------|------|--------|
| vault.k28.com | A | 192.225.5.4 dan 192.225.5.5 (obladi, desmond) |
| core.k28.com | A | 192.225.5.6 dan 192.225.5.7 (oblada, molly) |
| www.k28.com | CNAME | penny.k28.com. |
| static.k28.com | CNAME | abbey.k28.com. |

### Hasil

| Hostname | Hasil resolve | Sesuai |
|----------|---------------|--------|
| vault.k28.com | 192.225.5.4 dan 192.225.5.5 | Ya |
| core.k28.com | 192.225.5.6 dan 192.225.5.7 | Ya |
| www.k28.com | penny.k28.com. lalu 192.225.3.3 | Ya |
| static.k28.com | abbey.k28.com. lalu 192.225.4.2 | Ya |

- Hasil dari alpha, delta, prab, dan tedd identik.
- Urutan dua IP pada `vault` dan `core` bisa berbeda karena round robin, dan itu normal.
- Serial SOA di prab dan tedd sama (isi dengan angka dari screenshot).

### Kesimpulan
`vault` dan `core` mengarah ke masing-masing pasangan web statis dan dinamis, sedangkan `www` dan `static` menjadi alias gerbang utama. Hasil resolve konsisten di dua klien dan dua server DNS.

### Langkah Pengerjaan (Step by Step)

**1. Cek zona sebelum diubah (prab)**

```sh
cat /var/bind/k28.com
```

<!-- SS: zona sebelum ada vault/core/www/static -->
![Zona awal](img/soal7-zona-awal.png)

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
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" /var/bind/k28.com
```

**4. Cek zona lalu muat ulang named (prab)**

```sh
named-checkzone k28.com /var/bind/k28.com
pkill named
sleep 1
named -u named
```

<!-- SS: named-checkzone OK -->
![Cek zona](img/soal7-checkzone.png)

**5. Cek isi zona setelah diubah (prab)**

```sh
grep -E "^(vault|core|www|static)" /var/bind/k28.com
```

<!-- SS: 6 baris record -->
![Zona di prab](img/soal7-zona.png)

**6. Tes resolve dari prab**

```sh
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.2 $h.k28.com +short
done
```

<!-- SS: hasil dig di prab -->
![Tes prab](img/soal7-prab.png)

**7. Verifikasi dari klien pertama (alpha)**

Kalau `dig` belum ada: `apk add bind-tools`

```sh
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.2 $h.k28.com +short
done
```

<!-- SS: terminal alpha, prompt alpha:~# terlihat -->
![Verifikasi alpha](img/soal7-alpha.png)

**8. Verifikasi dari klien kedua (delta)**

Perintah sama seperti langkah 7.

<!-- SS: terminal delta, prompt delta:~# terlihat -->
![Verifikasi delta](img/soal7-delta.png)

**9. Cek sinkronisasi ke tedd**

```sh
dig @192.225.5.3 k28.com SOA +short
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.3 $h.k28.com +short
done
```

Kalau tedd masih menjawab data lama: `pkill named; rm -f /var/bind/slave/k28.com; named -u named; sleep 4`, lalu ulangi.

<!-- SS: serial sama dengan prab, jawaban identik -->
![Sinkronisasi tedd](img/soal7-tedd.png)

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

for h in vault core www static; do
    sed -i "/^$h[[:space:]]/d" $ZONA
done

cat >> $ZONA <<'EOF'
vault   IN  A      192.225.5.4
vault   IN  A      192.225.5.5
core    IN  A      192.225.5.6
core    IN  A      192.225.5.7
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF

sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" $ZONA

named-checkzone k28.com $ZONA || exit 1
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

for h in vault core www static; do
    echo "$h:"
    dig @192.225.5.2 $h.k28.com +short
done
echo "=== Isi zona ==="
grep -E "^(vault|core|www|static)" $ZONA
echo "=== Serial SOA ==="
dig @192.225.5.2 k28.com SOA +short
echo "=== Selesai ==="
EOT
chmod +x /root/soal7_prab.sh
/root/soal7_prab.sh
```

`soal7_cek.sh` (di alpha, delta, dan tedd):

```sh
cat > /root/soal7_cek.sh <<'EOT'
#!/bin/sh
echo "=== Cek soal 7 dari $(hostname) ==="
for s in 192.225.5.2 192.225.5.3; do
    echo "--- server $s ---"
    dig @$s k28.com SOA +short
    for h in vault core www static; do
        echo "$h:"
        dig @$s $h.k28.com +short
    done
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal7_cek.sh
/root/soal7_cek.sh
```

---
## Soal 8: Reverse Zone dan PTR (Master prab, Slave tedd)

### Tujuan
Mendeklarasikan reverse zone di prab (ns1) untuk segmen tempat abbey, penny, vault, dan core berada, menariknya sebagai slave di tedd (ns2), mengisi PTR, lalu memastikan query reverse dijawab authoritative.

### Pembagian Zona

| Segmen | Zona reverse | Isi |
|--------|--------------|-----|
| 192.225.3.0/24 | `3.225.192.in-addr.arpa` | penny (3.3) |
| 192.225.4.0/24 | `4.225.192.in-addr.arpa` | abbey (4.2) |
| 192.225.5.0/24 | `5.225.192.in-addr.arpa` | vault (5.4, 5.5), core (5.6, 5.7) |

### Record PTR

| IP | PTR |
|----|-----|
| 192.225.3.3 | penny.k28.com. |
| 192.225.4.2 | abbey.k28.com. |
| 192.225.5.4 | vault.k28.com. |
| 192.225.5.5 | vault.k28.com. |
| 192.225.5.6 | core.k28.com. |
| 192.225.5.7 | core.k28.com. |

### Hasil

| Query | Jawaban | Flag aa |
|-------|---------|---------|
| -x 192.225.3.3 | penny.k28.com. | Ya |
| -x 192.225.4.2 | abbey.k28.com. | Ya |
| -x 192.225.5.4 | vault.k28.com. | Ya |
| -x 192.225.5.6 | core.k28.com. | Ya |

- Query ke prab (`192.225.5.2`) dan tedd (`192.225.5.3`) sama-sama authoritative.
- Serial ketiga reverse zone sama di prab dan tedd (isi dengan angka dari screenshot).

### Kesimpulan
Tiga reverse zone (segmen 3.x, 4.x, 5.x) dideklarasikan di prab sebagai master dan ditarik tedd sebagai slave. Pencarian balik alamat penny, abbey, vault, dan core mengembalikan hostname yang benar dan dijawab authoritative oleh kedua server.

### Langkah Pengerjaan (Step by Step)

#### Di prab (master)

**1. Deklarasikan tiga zona di named.conf**

```sh
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
tail -40 /etc/bind/named.conf
```

<!-- SS: tiga blok zona master -->
![Deklarasi zona prab](img/soal8-namedconf-prab.png)

**2. Buat tiga file zona reverse**

```sh
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

<!-- SS: isi tiga file zona reverse -->
![File zona reverse](img/soal8-zona-reverse.png)

**3. Cek konfigurasi dan zona, lalu jalankan ulang named**

```sh
named-checkconf /etc/bind/named.conf
named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa
named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa
named-checkzone 5.225.192.in-addr.arpa /var/bind/5.225.192.in-addr.arpa
pkill named; sleep 1; named -u named
```

<!-- SS: named-checkconf diam, tiga OK -->
![Cek zona](img/soal8-checkzone.png)

**4. Tes reverse dari prab**

```sh
dig @192.225.5.2 -x 192.225.4.2 +short
dig @192.225.5.2 -x 192.225.5.6 +short
```

<!-- SS: abbey.k28.com. dan core.k28.com. -->
![Reverse prab](img/soal8-dig-prab.png)

#### Di tedd (slave)

**5. Deklarasikan zona sebagai slave**

```sh
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
named-checkconf /etc/bind/named.conf
pkill named; sleep 1; named -u named
sleep 3
tail -30 /etc/bind/named.conf
ls /var/bind/slave
```

Hasil yang benar: `ls` menampilkan empat file (`k28.com` dan tiga zona reverse).

<!-- SS: deklarasi slave dan empat file -->
![Slave tedd](img/soal8-slave-tedd.png)

#### Verifikasi authoritative

**6. Query ke tedd**

```sh
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
    dig @192.225.5.3 -x $ip +noall +comments +answer | grep -E "^;; flags|PTR"
done
```

<!-- SS: flag aa dan PTR benar dari tedd -->
![Authoritative tedd](img/soal8-aa-tedd.png)

**7. Query ke prab**

```sh
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
    dig @192.225.5.2 -x $ip +noall +comments +answer | grep -E "^;; flags|PTR"
done
```

<!-- SS: flag aa dan PTR benar dari prab -->
![Authoritative prab](img/soal8-aa-prab.png)

**8. Cek sinkronisasi serial**

```sh
for z in 3 4 5; do
    dig @192.225.5.2 $z.225.192.in-addr.arpa SOA +short
    dig @192.225.5.3 $z.225.192.in-addr.arpa SOA +short
done
```

<!-- SS: serial sama di keenam baris -->
![Sinkronisasi serial](img/soal8-serial.png)

### Versi Otomatis (Script)

Script aman dijalankan ulang: deklarasi zona hanya ditambah kalau belum ada, dan serial memakai `date +%s`.

**`soal8_prab.sh` (prab)**

```sh
cat > /root/soal8_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (prab) ==="

CONF="/etc/bind/named.conf"
SERIAL=$(date +%s)

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa; do
    if ! grep -q "zone \"$z\"" $CONF; then
        cat >> $CONF <<EOF

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

mkzone() {
    # $1 = zona, $2 = isi PTR
    cat > /var/bind/$1 <<EOF
\$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            $SERIAL  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
$2
EOF
}

mkzone 3.225.192.in-addr.arpa "3   IN  PTR penny.k28.com."
mkzone 4.225.192.in-addr.arpa "2   IN  PTR abbey.k28.com."
mkzone 5.225.192.in-addr.arpa "4   IN  PTR vault.k28.com.
5   IN  PTR vault.k28.com.
6   IN  PTR core.k28.com.
7   IN  PTR core.k28.com."

echo "=== Cek konfigurasi ==="
named-checkconf $CONF || exit 1
for z in 3 4 5; do
    named-checkzone $z.225.192.in-addr.arpa /var/bind/$z.225.192.in-addr.arpa || exit 1
done

echo "=== Muat ulang named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "=== Tes reverse di prab ==="
for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
    echo -n "$ip: "
    dig @192.225.5.2 -x $ip +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_prab.sh
/root/soal8_prab.sh
```

**`soal8_tedd.sh` (tedd, jalankan setelah prab)**

```sh
cat > /root/soal8_tedd.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (tedd) ==="

CONF="/etc/bind/named.conf"

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa 5.225.192.in-addr.arpa; do
    if ! grep -q "zone \"$z\"" $CONF; then
        cat >> $CONF <<EOF

zone "$z" IN {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/slave/$z";
};
EOF
    fi
done

named-checkconf $CONF || exit 1

# Hapus salinan lama supaya selalu menarik versi terbaru dari prab
pkill named 2>/dev/null
sleep 1
rm -f /var/bind/slave/k28.com /var/bind/slave/*.in-addr.arpa
named -u named
sleep 4

echo "=== File slave ==="
ls /var/bind/slave

echo "=== Cek authoritative (harus ada aa) ==="
for s in 192.225.5.3 192.225.5.2; do
    echo "--- server $s ---"
    for ip in 192.225.3.3 192.225.4.2 192.225.5.4 192.225.5.6; do
        dig @$s -x $ip +noall +comments +answer | grep -E "^;; flags|PTR"
    done
done

echo "=== Serial SOA ==="
for z in 3 4 5; do
    dig @192.225.5.2 $z.225.192.in-addr.arpa SOA +short
    dig @192.225.5.3 $z.225.192.in-addr.arpa SOA +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_tedd.sh
/root/soal8_tedd.sh
```

---

## Urutan Menjalankan Semua Script

Setelah node direstart (named tidak menyala otomatis dan `soal4_*` menimpa `named.conf` serta zona), jalankan berurutan:

```sh
# prab
/root/soal4_prab.sh
/root/soal5_prab.sh
/root/soal7_prab.sh
/root/soal8_prab.sh

# tedd
/root/soal4_tedd.sh
/root/soal8_tedd.sh

# semua node non-router
/root/resolver_soal4.sh
```ne hilang. Kalau terlanjur, jalankan `soal8_prab.sh` lalu `soal8_tedd.sh` untuk memasang kembali.

---
#SOAL 9 — WEB STATIS APACHE DAN AUTOINDEX

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

Pengujian:

```bash
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"
```

Hasil:

```text
dokumen1.txt
dokumen2.txt
laporan/
```

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

Cek konfigurasi dan jalankan Apache:

```bash
httpd -t
ps | grep -q "[h]ttpd" && httpd -k restart || httpd
```

Kemudian cek isi `/arsip/`:

```bash
curl -s http://localhost/arsip/ | grep -E "dokumen|laporan"
```

Hasil:

```text
dokumen1.txt
dokumen2.txt
laporan/
```

**Konfigurasi dan hasil pengujian Apache pada `desmond`.**
<img width="933" height="140" alt="Screenshot 2026-09-30 183604" src="https://github.com/user-attachments/assets/a2d058cf-7769-413c-9710-eab8c22041a6" />

### 4. Pengujian Hostname dari `delta`

Pengujian dilakukan dari `delta` untuk memastikan hostname dapat digunakan.

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

Selanjutnya dilakukan pengujian web menggunakan hostname:

```bash
curl -s http://obladi.k28.com/arsip/ | grep -E "dokumen|laporan"

curl -s http://desmond.k28.com/arsip/ | grep -E "dokumen|laporan"

curl -s http://vault.k28.com/arsip/ | grep -E "dokumen|laporan"
```

Hasil menampilkan:

```text
dokumen1.txt
dokumen2.txt
laporan/
```

**Pengujian hostname dan directory listing dari `delta`.**
<img width="950" height="300" alt="Screenshot 2026-09-30 183747" src="https://github.com/user-attachments/assets/2cfcd8e5-cb07-4a2c-b867-b0f11bf9734c" />

### 5. Pengujian Folder `laporan`

Untuk memastikan subfolder juga dapat ditelusuri:

```bash
curl -s http://vault.k28.com/arsip/laporan/ | grep "a.txt"
```

Hasil:

```text
a.txt
```

Kemudian dilakukan pengujian langsung:

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

**Hasil directory listing `vault.k28.com/arsip/`.**
<img width="959" height="232" alt="Screenshot 2026-09-30 184638" src="https://github.com/user-attachments/assets/0833e1a7-fa31-442d-a7b2-d29fb8cc4553" />

## Kesimpulan

Konfigurasi web statis menggunakan Apache berhasil dilakukan. Fitur AutoIndex pada direktori `/arsip/` juga berhasil menampilkan daftar file dan folder. Pengujian menggunakan hostname `obladi.k28.com`, `desmond.k28.com`, dan `vault.k28.com` berhasil dilakukan tanpa menggunakan IP address secara langsung.

## Versi Otomatis (Script)

### Node `obladi`

```bash
cat > soal9_setup.sh <<'EOF'
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
cara menjelankannya:
```
chmod +x soal9_setup.sh
./soal9_setup.sh
```

### Node `desmond`

```bash
cat > soal9_setup.sh <<'EOF'
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
cara menjelankannya:
```
chmod +x soal9_setup.sh
./soal9_setup.sh
```

### Pengujian Hostname

Dilakukan dari node yang digunakan untuk pengujian, misalnya `delta`:

```bash
curl http://vault.k28.com/arsip/
```

---
# Soal 10 – Web Dinamis PHP-FPM dengan Nginx

## Tujuan

Percobaan ini bertujuan untuk menjalankan layanan web dinamis menggunakan **Nginx dan PHP-FPM** pada node **Oblada** di area core. Website dibuat sederhana dengan dua halaman, yaitu halaman beranda dan halaman profil. Selain itu, diterapkan aturan rewrite agar halaman profil dapat diakses menggunakan URL `/profil` tanpa menuliskan `.php`. Pengujian dilakukan menggunakan hostname `oblada.k28.com`.

---

## Langkah 1 – Masuk ke Node Oblada

Konfigurasi web dilakukan pada node **Oblada**.

**Console: `oblada`**

```sh
apk update
```

## Langkah 2 – Install Nginx dan PHP-FPM

Masih di console **Oblada**, install Nginx dan PHP-FPM:

```sh
apk add nginx php84 php84-fpm
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

## Langkah 6 – Menjalankan PHP-FPM

Jalankan PHP-FPM:

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

Jalankan Nginx:

```sh
nginx
```

Jika Nginx sudah berjalan, gunakan:

```sh
nginx -s reload
```

Kemudian cek port 80:

```sh
netstat -tlnp 2>/dev/null | grep ':80'
```

Pastikan proses yang menggunakan port 80 adalah Nginx.


## Langkah 10 – Pengujian Beranda pada Node Oblada

Masih di console **Oblada**, lakukan pengujian menggunakan hostname:

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

```sh
curl http://oblada.k28.com/
```

Jika halaman beranda tampil, berarti layanan web dapat diakses menggunakan hostname.

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


## Langkah 13 – Pengujian Menggunakan Lynx

Pengujian juga dilakukan menggunakan browser teks **Lynx**.

**Console: `delta`**

Untuk halaman beranda:

```sh
lynx -reload http://oblada.k28.com/
```

<img width="959" height="509" alt="Screenshot 2026-09-30 214445" src="https://github.com/user-attachments/assets/95121f34-9890-45ab-a88a-9d2342a3ca5f" />

<img width="959" height="506" alt="Screenshot 2026-09-30 214530" src="https://github.com/user-attachments/assets/1b9180b6-9989-4298-a6e1-b7775e8e1682" />

Kemudian untuk halaman profil:

```sh
lynx -reload http://oblada.k28.com/profil
```

Pada halaman profil ditampilkan informasi:

```text
May & AL
Kelompok K28 - The Mesh
Node: oblada
Kembali ke Beranda
```

Pengujian menggunakan hostname `oblada.k28.com`, bukan menggunakan IP address.

<img width="959" height="501" alt="Screenshot 2026-09-30 214607" src="https://github.com/user-attachments/assets/358ca289-4ce5-41bc-9414-bd9303bd10a1" />

<img width="959" height="501" alt="Screenshot 2026-09-30 214635" src="https://github.com/user-attachments/assets/54519f82-92f3-4d4c-8122-2fdd5b94d25d" />

## Kesimpulan

Berdasarkan konfigurasi dan pengujian yang dilakukan, layanan web dinamis berhasil dijalankan pada node **Oblada** menggunakan **Nginx dan PHP-FPM**. Website memiliki halaman beranda dan halaman profil. Aturan rewrite berhasil membuat halaman profil dapat diakses menggunakan URL bersih `/profil` tanpa akhiran `.php`. Pengujian dilakukan menggunakan hostname `oblada.k28.com`.

## Versi Otomatis (Script)

### Node `oblada`

Buat dan jalankan script:

```sh
cat > soal10_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx php84 php84-fpm

mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d

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

cat > /var/www/core/profil.php <<'PHP'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: oblada</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
PHP

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

php-fpm84

nginx -t || exit 1

nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 10 OBLADA SELESAI ==="
EOF

chmod +x soal10_setup.sh
./soal10_setup.sh
```

---

### Node `molly`

Buat dan jalankan script:

```sh
cat > soal10_setup.sh <<'EOF'
#!/bin/sh

apk update
apk add nginx php84 php84-fpm

mkdir -p /var/www/core
mkdir -p /etc/nginx/http.d

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

cat > /var/www/core/profil.php <<'PHP'
<?php
echo "<h1>Profil Kelompok</h1>";
echo "<p><b>May & AL</b></p>";
echo "<p>Kelompok K28 - The Mesh</p>";
echo "<p>Node: molly</p>";
echo "<p><a href='/'>Kembali ke Beranda</a></p>";
?>
PHP

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

php-fpm84

nginx -t || exit 1

nginx 2>/dev/null || nginx -s reload

echo "=== SOAL 10 MOLLY SELESAI ==="
EOF

chmod +x soal10_setup.sh
./soal10_setup.sh
```

### Pengujian dari Node `delta`

```sh
curl http://oblada.k28.com/
curl http://oblada.k28.com/profil

curl http://molly.k28.com/
curl http://molly.k28.com/profil
```

Pengujian menggunakan Lynx:

```sh
lynx -reload http://oblada.k28.com/
lynx -reload http://oblada.k28.com/profil

lynx -reload http://molly.k28.com/
lynx -reload http://molly.k28.com/profil
```
---


