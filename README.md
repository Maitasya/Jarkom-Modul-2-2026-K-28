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






