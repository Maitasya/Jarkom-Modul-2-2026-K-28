# Jarkom-Modul-2-2026-K-28

## Kelompok K-28

|            Nama           |     NRP    |
| :-----------------------: | :--------: |
|   Maitasya Rohmatul Ula   | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

---

# Soal 1 — Konfigurasi IP Address dan Default Gateway

## Tujuan

Melakukan konfigurasi alamat IP dan default gateway pada seluruh node *The Mesh* sesuai dengan pembagian jaringan pada topologi. Setiap jaringan menggunakan prefix `192.225.x.x`, sedangkan `rootkit` berperan sebagai router/gateway utama yang menghubungkan seluruh jaringan internal.

<img width="959" height="415" alt="image" src="https://github.com/user-attachments/assets/6de7ff0a-14f3-425f-a54d-55c880b5ca2b" />

### Tabel Konfigurasi IP

| No | Simpul  | Interface | IP Address     | Gateway     |
| -- | ------- | --------- | -------------- | ----------- |
| 1  | rootkit | eth1      | 192.225.5.1/24 | -           |
| 2  | rootkit | eth2      | 192.225.4.1/24 | -           |
| 3  | rootkit | eth3      | 192.225.3.1/24 | -           |
| 4  | rootkit | eth4      | 192.225.1.1/24 | -           |
| 5  | rootkit | eth5      | 192.225.2.1/24 | -           |
| 6  | alpha   | eth0      | 192.225.1.2/24 | 192.225.1.1 |
| 7  | beta    | eth0      | 192.225.1.3/24 | 192.225.1.1 |
| 8  | gamma   | eth0      | 192.225.1.4/24 | 192.225.1.1 |
| 9  | delta   | eth0      | 192.225.2.2/24 | 192.225.2.1 |
| 10 | epsilon | eth0      | 192.225.2.3/24 | 192.225.2.1 |
| 11 | abbey   | eth0      | 192.225.3.2/24 | 192.225.3.1 |
| 12 | penny   | eth0      | 192.225.3.3/24 | 192.225.3.1 |
| 13 | obladi  | eth0      | 192.225.4.2/24 | 192.225.4.1 |
| 14 | desmond | eth0      | 192.225.4.3/24 | 192.225.4.1 |
| 15 | oblada  | eth0      | 192.225.4.4/24 | 192.225.4.1 |
| 16 | molly   | eth0      | 192.225.4.5/24 | 192.225.4.1 |
| 17 | prab    | eth0      | 192.225.5.2/24 | 192.225.5.1 |
| 18 | tedd    | eth0      | 192.225.5.3/24 | 192.225.5.1 |

### Konfigurasi

Konfigurasi IP pada setiap node dilakukan melalui file `/etc/network/interfaces` dengan format berikut:

```bash
auto eth0
iface eth0 inet static
    address <IP_ADDRESS>
    netmask 255.255.255.0
    gateway <GATEWAY>
```

Pada `rootkit`, interface `eth1` sampai `eth5` dikonfigurasi sebagai gateway untuk masing-masing jaringan.

### Verifikasi

Konfigurasi IP diperiksa menggunakan:

```bash
ip addr
```

Untuk melihat IP secara ringkas:

```bash
ip -br addr
```

Default gateway diperiksa menggunakan:

```bash
ip route
```

Konektivitas kemudian diuji menggunakan:

```bash
ping -c 4 <IP_GATEWAY>
```

Hasil verifikasi menunjukkan bahwa alamat IP dan default gateway telah dikonfigurasi sesuai dengan pembagian jaringan pada topologi.


Selain pemeriksaan manual, dibuat script `.sh` pada masing-masing node untuk membantu melakukan pengecekan konfigurasi dan konektivitas jaringan. Script tersebut digunakan sebagai verifikasi tambahan terhadap hasil konfigurasi IP dan gateway yang telah diterapkan.

## Script Verifikasi Node

Untuk memastikan konfigurasi jaringan setiap node berjalan dengan baik, digunakan script pengecekan `.sh`. Script digunakan untuk mengecek IP, gateway, routing, koneksi internet, serta konektivitas dengan node lain.

Script dibuat pada masing-masing node dengan nama:

| Node    | Script               |
| ------- | -------------------- |
| rootkit | `cek_noderootkit.sh` |
| alpha   | `cek_nodealpha.sh`   |
| beta    | `cek_nodebeta.sh`    |
| gamma   | `cek_nodegamma.sh`   |
| delta   | `cek_nodedelta.sh`   |
| epsilon | `cek_nodeepsilon.sh` |
| abbey   | `cek_nodeabbey.sh`   |
| penny   | `cek_nodepenny.sh`   |
| prab    | `cek_prab.sh`    |
| tedd    | `cek_tedd.sh`    |
| obladi  | `cek_obladi.sh`  |
| desmond | `cek_desmond.sh` |
| oblada  | `cek_oblada.sh`  |
| molly   | `cek_molly.sh`   |

Script dijalankan dengan memberikan permission terlebih dahulu:

```bash
chmod +x cek_noderootkit.sh
```

Kemudian dijalankan menggunakan:

```bash
./cek_noderootkit.sh
```

Pada node lainnya, nama script disesuaikan dengan nama node. Hasil dari setiap script digunakan untuk memastikan konfigurasi dan konektivitas seluruh node telah berjalan sesuai topologi.

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
# Soal 4: DNS Master-Slave dan Resolver (K28)

## Ringkasan

| Node | Peran | IP |
|---|---|---|
| prab | DNS master (ns1) | 192.225.5.2 |
| tedd | DNS slave (ns2) | 192.225.5.3 |
| penny | Gerbang aplikasi dinamis (A record apex) | 192.225.3.2 |

Tujuan:
1. prab menjadi master authoritative untuk zona `k28.com` (SOA, NS, A record, notify, allow-transfer, forwarders `192.168.122.1`).
2. tedd menarik zona dari prab dan menjawab secara authoritative.
3. Semua node non-router memakai urutan resolver: prab, tedd, `192.168.122.1`.

---

## Langkah Pengerjaan

### 1. Persiapan (prab dan tedd)

Pastikan node punya internet dan saling terhubung:

```sh
cat /etc/resolv.conf
ping -c 2 google.com
ping -c 2 192.225.5.3   # dari prab
ping -c 2 192.225.5.2   # dari tedd
```

Install bind:

```sh
apk update
apk add bind bind-tools
```

### 2. Konfigurasi prab (master)

Buat `named.conf`:

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

Buat file zona:

```sh
cat > /var/bind/k28.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            2026092901  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.k28.com.
@       IN  NS  tedd.k28.com.
prab    IN  A   192.225.5.2
tedd    IN  A   192.225.5.3
@       IN  A   192.225.3.2
EOF
```

Cek konfigurasi lalu jalankan named:

```sh
named-checkconf /etc/bind/named.conf
named-checkzone k28.com /var/bind/k28.com
mkdir -p /var/run/named
chown named:named /var/run/named
pkill named
sleep 1
named -u named
```

Hasil `named-checkzone` yang benar: `loaded serial 2026092901` dan `OK`.

![named-checkzone](img/4-prab-checkzone.png)

### 3. Verifikasi prab

```sh
dig @192.225.5.2 k28.com
dig @192.225.5.2 prab.k28.com +short
dig @192.225.5.2 tedd.k28.com +short
dig @192.225.5.2 k28.com NS +short
dig @192.225.5.2 google.com +short
cat /etc/bind/named.conf
```

Hasil yang benar:
- `k28.com` punya `flags: qr aa` dan menjawab `192.225.3.2` (IP penny).
- `prab.k28.com` menjawab `192.225.5.2`, `tedd.k28.com` menjawab `192.225.5.3`.
- `NS` menjawab `prab.k28.com.` dan `tedd.k28.com.`.
- `google.com` menjawab beberapa IP (forwarder dan recursion berjalan).

![dig prab](img/4-prab-dig-aa.png)

### 4. Konfigurasi tedd (slave)

Siapkan direktori slave (file lama dihapus supaya zona benar-benar ditarik dari prab):

```sh
mkdir -p /var/bind/slave
chown named:named /var/bind/slave
chmod 775 /var/bind/slave
rm -f /var/bind/slave/k28.com
```

Buat `named.conf`:

```sh
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
```

Jalankan named (setelah prab menyala):

```sh
named-checkconf /etc/bind/named.conf
mkdir -p /var/run/named
chown named:named /var/run/named
pkill named
sleep 1
named -u named
sleep 5
```

### 5. Verifikasi tedd

```sh
ls -l /var/bind/slave/
dig @192.225.5.3 k28.com
dig @192.225.5.2 k28.com SOA +short
dig @192.225.5.3 k28.com SOA +short
cat /etc/bind/named.conf
```

Hasil yang benar:
- File `k28.com` ada di `/var/bind/slave/` (hasil transfer dari prab).
- `dig @192.225.5.3 k28.com` punya `flags: qr aa`, TTL `604800`, jawaban `192.225.3.2`.
- Serial SOA prab dan tedd sama: `2026092901`.

![tedd slave](img/4-tedd-slave-file.png)

### 6. Ubah resolver di semua node non-router

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

### 7. Verifikasi resolver (tiap node)

```sh
cat /etc/resolv.conf
dig k28.com +short
dig prab.k28.com +short
dig google.com +short
```

Hasil yang benar:
- Urutan resolver: `192.225.5.2`, `192.225.5.3`, `192.168.122.1`.
- `k28.com` menjawab `192.225.3.2`.
- `prab.k28.com` menjawab `192.225.5.2`.
- `google.com` tetap menjawab.

![resolver](img/4-resolver-alpha.png)

---

## Menjalankan Script

Seluruh langkah di atas sudah dibungkus menjadi tiga script yang diletakkan di `/root`.

| Script | Node | Fungsi |
|---|---|---|
| `soal4_prab.sh` | prab | Install bind, konfigurasi master, buat zona, jalankan named |
| `soal4_tedd.sh` | tedd | Install bind, konfigurasi slave, jalankan named |
| `resolver_soal4.sh` | 13 node non-router | Ubah urutan resolver |

Urutan menjalankan (penting: tedd butuh prab sudah hidup):

```sh
# 1. Di prab
chmod +x /root/soal4_prab.sh
/root/soal4_prab.sh

# 2. Di tedd (setelah prab menyala), lalu tunggu 5-10 detik
chmod +x /root/soal4_tedd.sh
/root/soal4_tedd.sh

# 3. Di semua node non-router
chmod +x /root/resolver_soal4.sh
/root/resolver_soal4.sh
```

Setelah node direstart, `named` tidak menyala otomatis dan `resolv.conf` bisa ter-reset, jadi jalankan ulang ketiga script dengan urutan yang sama.

### Isi `soal4_prab.sh`

```sh
#!/bin/sh
echo "=== Konfigurasi DNS PRAB - K28 ==="

DOMAIN="k28.com"
IP_PRAB="192.225.5.2"
IP_TEDD="192.225.5.3"
IP_PENNY="192.225.3.2"

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
            2026092901  ; Serial
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
```

### Isi `soal4_tedd.sh`

```sh
#!/bin/sh
echo "=== Konfigurasi DNS TEDD - K28 ==="

DOMAIN="k28.com"
IP_PRAB="192.225.5.2"
IP_TEDD="192.225.5.3"

apk update
apk add bind bind-tools

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
pkill named 2>/dev/null
sleep 1
named -u named

echo "=== Selesai ==="
```

### Isi `resolver_soal4.sh`

```sh
#!/bin/sh
cat > /etc/resolv.conf <<'EOT'
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
EOT
cat /etc/resolv.conf
```

---


