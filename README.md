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

<img width="742" height="241" alt="Screenshot 2026-09-29 141210" src="https://github.com/user-attachments/assets/8298bcab-537e-4da8-bfa3-7fd19a141003" />


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

<img width="749" height="502" alt="Screenshot 2026-09-29 141227" src="https://github.com/user-attachments/assets/6b66c800-2de0-4a06-96ef-3b93c6827d3c" />
<img width="739" height="171" alt="Screenshot 2026-09-29 141246" src="https://github.com/user-attachments/assets/00dc2c2a-8e39-4400-aa0c-976c9b30baaf" />



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

<img width="736" height="210" alt="Screenshot 2026-09-29 141419" src="https://github.com/user-attachments/assets/6dbc0a90-7e98-4db4-acd0-0b4a175a17db" />
<img width="738" height="511" alt="Screenshot 2026-09-29 141432" src="https://github.com/user-attachments/assets/236b40d0-6c24-4f3b-a9d6-f56ce2c2a112" />
<img width="751" height="92" alt="Screenshot 2026-09-29 141746" src="https://github.com/user-attachments/assets/898410dd-a79a-48ce-a92c-157b7e8c128b" />
<img width="753" height="413" alt="Screenshot 2026-09-29 141758" src="https://github.com/user-attachments/assets/351865ea-47aa-403c-a245-c11651d6dc82" />


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
## Soal 7: Web Server Statis dan Dinamis pada DNS

### Tujuan
Menambahkan record pada zona `k28.com` untuk mengelompokkan node berdasarkan peran, lalu memverifikasi dari dua klien bahwa hasil resolve konsisten.

### Pembagian Peran

| Node | IP | Peran |
|------|----|-------|
| abbey | 192.225.3.2 | Gerbang utama |
| penny | 192.225.3.3 | Gerbang utama |
| obladi | 192.225.4.2 | Web statis |
| desmond | 192.225.4.3 | Web statis |
| oblada | 192.225.4.4 | Web dinamis |
| molly | 192.225.4.5 | Web dinamis |

### Record yang Ditambahkan

| Nama | Tipe | Tujuan |
|------|------|--------|
| vault.k28.com | A | 192.225.4.2 dan 192.225.4.3 (obladi, desmond) |
| core.k28.com | A | 192.225.4.4 dan 192.225.4.5 (oblada, molly) |
| www.k28.com | CNAME | penny.k28.com. |
| static.k28.com | CNAME | abbey.k28.com. |

### Hasil

| Hostname | Hasil resolve | Sesuai |
|----------|---------------|--------|
| vault.k28.com | 192.225.4.2 dan 192.225.4.3 | Ya |
| core.k28.com | 192.225.4.4 dan 192.225.4.5 | Ya |
| www.k28.com | penny.k28.com. lalu 192.225.3.3 | Ya |
| static.k28.com | abbey.k28.com. lalu 192.225.3.2 | Ya |

- Hasil dari alpha, delta, prab, dan tedd identik.
- Urutan dua IP pada `vault` dan `core` bisa berbeda karena round robin, dan itu normal.
- Serial SOA di prab dan tedd sama (ganti dengan angka serial dari screenshot).

### Kesimpulan
Record `vault` dan `core` mengarah ke masing-masing pasangan web statis dan dinamis, sedangkan `www` dan `static` menjadi alias untuk gerbang utama. Hasil resolve konsisten di dua klien dan dua server DNS.

### Langkah Pengerjaan (Step by Step)

**1. Cek isi zona sebelum diubah (di prab)**

```sh
cat /var/bind/k28.com
```

**2. Tambahkan record ke zona (di prab)**

```sh
cat >> /var/bind/k28.com <<'EOF'
vault   IN  A      192.225.4.2
vault   IN  A      192.225.4.3
core    IN  A      192.225.4.4
core    IN  A      192.225.4.5
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF
```

**3. Naikkan serial SOA supaya tedd menarik zona baru (di prab)**

```sh
sed -i "s/[0-9]\{10\}\( *; Serial\)/$(date +%s)\1/" /var/bind/k28.com
```

**4. Cek zona lalu muat ulang named (di prab)**

```sh
named-checkzone k28.com /var/bind/k28.com
pkill named
named -u named
```

**5. Cek isi zona setelah diubah (di prab)**

```sh
grep -E "^(vault|core|www|static)" /var/bind/k28.com
```

<img width="740" height="157" alt="Screenshot 2026-09-30 010555" src="https://github.com/user-attachments/assets/2e0b4ae7-6234-4d15-8977-862f7f4f4760" />


**6. Tes resolve dari prab**

```sh
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.2 $h.k28.com +short
done
```

<img width="751" height="331" alt="image" src="https://github.com/user-attachments/assets/aa26d957-9426-42b7-8ac5-95f4836ff51e" />


**7. Verifikasi dari klien pertama (alpha)**

Kalau `dig` belum ada: `apk add bind-tools`

```sh
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.2 $h.k28.com +short
done
```
<img width="746" height="421" alt="Screenshot 2026-09-30 010719" src="https://github.com/user-attachments/assets/b21cfc65-a811-4f9d-a976-714fc4736fd1" />


**8. Verifikasi dari klien kedua (delta)**

Perintah sama seperti langkah 7.

<img width="750" height="434" alt="Screenshot 2026-09-30 010741" src="https://github.com/user-attachments/assets/bf3c52fe-933b-4fa9-85d8-bea050e60958" />


**9. Cek sinkronisasi ke server slave (tedd)**

```sh
dig @192.225.5.3 k28.com SOA +short
for h in vault core www static; do
    echo "$h:"; dig @192.225.5.3 $h.k28.com +short
done
```
<img width="663" height="407" alt="Screenshot 2026-09-30 010807" src="https://github.com/user-attachments/assets/3c4f8418-014c-4526-b403-2ca6286acae1" />


### Versi script

Langkah 2 sampai 6 dirangkum dalam satu script di prab. Aman dijalankan ulang karena record lama dihapus dulu.

```sh
cat > /root/soal7_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 7: vault, core, CNAME ==="

ZONA="/var/bind/k28.com"

if [ ! -f "$ZONA" ]; then
    echo "File zona tidak ada. Jalankan soal4_prab.sh dulu."
    exit 1
fi

# Hapus record lama supaya tidak dobel kalau script dijalankan ulang
for h in vault core www static; do
    sed -i "/^$h[[:space:]]/d" $ZONA
done

cat >> $ZONA <<'EOF'
vault   IN  A      192.225.4.2
vault   IN  A      192.225.4.3
core    IN  A      192.225.4.4
core    IN  A      192.225.4.5
www     IN  CNAME  penny.k28.com.
static  IN  CNAME  abbey.k28.com.
EOF

# Naikkan serial supaya tedd menarik zona baru
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

Script verifikasi untuk alpha, delta, dan tedd (langkah 7 sampai 9):

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
## Soal 8: Reverse Zone dan PTR (Master prab, Slave tedd)

### Tujuan
Mendeklarasikan reverse zone di prab (ns1) untuk segmen tempat abbey, penny, vault, dan core berada, menariknya sebagai slave di tedd (ns2), mengisi PTR, lalu memastikan query reverse dijawab authoritative.

### Pembagian Zona

| Segmen | Zona reverse | Isi |
|--------|--------------|-----|
| 192.225.3.0/24 | `3.225.192.in-addr.arpa` | abbey (3.2), penny (3.3) |
| 192.225.4.0/24 | `4.225.192.in-addr.arpa` | vault (4.2, 4.3), core (4.4, 4.5) |

### Record PTR

| IP | PTR |
|----|-----|
| 192.225.3.2 | abbey.k28.com. |
| 192.225.3.3 | penny.k28.com. |
| 192.225.4.2 | vault.k28.com. |
| 192.225.4.3 | vault.k28.com. |
| 192.225.4.4 | core.k28.com. |
| 192.225.4.5 | core.k28.com. |

### Hasil

| Query | Jawaban | Flag aa |
|-------|---------|---------|
| -x 192.225.3.2 | abbey.k28.com. | Ya |
| -x 192.225.3.3 | penny.k28.com. | Ya |
| -x 192.225.4.2 | vault.k28.com. | Ya |
| -x 192.225.4.4 | core.k28.com. | Ya |

- Query ke prab (`192.225.5.2`) dan tedd (`192.225.5.3`) sama-sama authoritative.
- Serial kedua reverse zone sama di prab dan tedd (`2026093001`), jadi transfer sudah sinkron.

### Kesimpulan
Reverse zone untuk segmen 3.x dan 4.x sudah dideklarasikan di prab sebagai master dan ditarik tedd sebagai slave. Pencarian balik alamat abbey, penny, vault, dan core mengembalikan hostname yang benar dan dijawab authoritative oleh kedua server.

### Langkah Pengerjaan (Step by Step)

#### Di prab (master)

**1. Deklarasikan kedua zona di named.conf**

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
EOF
tail -30 /etc/bind/named.conf
```
<img width="687" height="645" alt="Screenshot 2026-09-30 013757" src="https://github.com/user-attachments/assets/5a1b8b51-d1c9-4b0d-88f0-d9019c5a1f83" />


**2. Buat file zona reverse segmen 3 dan segmen 4**

```sh
cat > /var/bind/3.225.192.in-addr.arpa <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            2026093001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
2   IN  PTR abbey.k28.com.
3   IN  PTR penny.k28.com.
EOF

cat > /var/bind/4.225.192.in-addr.arpa <<'EOF'
$TTL 604800
@   IN  SOA prab.k28.com. root.k28.com. (
            2026093001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative Cache TTL
;
@   IN  NS  prab.k28.com.
@   IN  NS  tedd.k28.com.
2   IN  PTR vault.k28.com.
3   IN  PTR vault.k28.com.
4   IN  PTR core.k28.com.
5   IN  PTR core.k28.com.
EOF

cat /var/bind/3.225.192.in-addr.arpa
cat /var/bind/4.225.192.in-addr.arpa
```

<img width="557" height="589" alt="Screenshot 2026-09-30 013933" src="https://github.com/user-attachments/assets/6dead4f5-08e5-456b-98d2-acf9f18c3162" />


**3. Cek konfigurasi dan zona, lalu jalankan ulang named**

```sh
named-checkconf /etc/bind/named.conf
named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa
named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa
pkill named; sleep 1; named -u named
```

<img width="685" height="164" alt="Screenshot 2026-09-30 013954" src="https://github.com/user-attachments/assets/9fc8830a-a5e7-46cc-b5c5-4f76d50f7881" />


**4. Tes reverse lookup dari prab**

```sh
dig @192.225.5.2 -x 192.225.3.2 +short
dig @192.225.5.2 -x 192.225.4.4 +short
```

<img width="482" height="115" alt="Screenshot 2026-09-30 014012" src="https://github.com/user-attachments/assets/9106b7f9-ed95-44c5-abb6-8f10b9b01c37" />


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
EOF
named-checkconf /etc/bind/named.conf
pkill named; sleep 1; named -u named
sleep 3
tail -20 /etc/bind/named.conf
ls /var/bind/slave
```
<img width="539" height="491" alt="Screenshot 2026-09-30 014028" src="https://github.com/user-attachments/assets/0e022f89-00b7-4bf4-a463-19b630d51ee4" />


#### Verifikasi authoritative

**6. Query ke tedd**

```sh
dig @192.225.5.3 -x 192.225.3.2 | grep -E "flags|PTR"
dig @192.225.5.3 -x 192.225.3.3 | grep -E "flags|PTR"
dig @192.225.5.3 -x 192.225.4.2 | grep -E "flags|PTR"
dig @192.225.5.3 -x 192.225.4.4 | grep -E "flags|PTR"
```<img width="669" height="429" alt="Screenshot 2026-09-30 014053" src="https://github.com/user-attachments/assets/aa92e0b7-0f9d-4736-b681-17a7d8341751" />


**7. Query ke prab**

```sh
dig @192.225.5.2 -x 192.225.3.2 | grep -E "flags|PTR"
dig @192.225.5.2 -x 192.225.3.3 | grep -E "flags|PTR"
dig @192.225.5.2 -x 192.225.4.2 | grep -E "flags|PTR"
dig @192.225.5.2 -x 192.225.4.4 | grep -E "flags|PTR"
```

<img width="664" height="433" alt="Screenshot 2026-09-30 014140" src="https://github.com/user-attachments/assets/df205efd-ba1a-427d-8dc3-5979feb21c93" />


**8. Cek sinkronisasi serial**

```sh
dig @192.225.5.2 3.225.192.in-addr.arpa SOA +short
dig @192.225.5.3 3.225.192.in-addr.arpa SOA +short
dig @192.225.5.2 4.225.192.in-addr.arpa SOA +short
dig @192.225.5.3 4.225.192.in-addr.arpa SOA +short
```
<img width="644" height="174" alt="Screenshot 2026-09-30 014225" src="https://github.com/user-attachments/assets/b90ad45a-c31a-4479-aa27-54b64b07b274" />


### Versi Otomatis (Script)

Script aman dijalankan ulang: deklarasi zona di `named.conf` hanya ditambah kalau belum ada, dan serial memakai `date +%s` (jadi angkanya berbeda dari langkah manual).

**`soal8_prab.sh` (jalankan di prab)**

```sh
cat > /root/soal8_prab.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (prab) ==="

CONF="/etc/bind/named.conf"
SERIAL=$(date +%s)

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa; do
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

cat > /var/bind/3.225.192.in-addr.arpa <<EOF
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
2   IN  PTR abbey.k28.com.
3   IN  PTR penny.k28.com.
EOF

cat > /var/bind/4.225.192.in-addr.arpa <<EOF
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
2   IN  PTR vault.k28.com.
3   IN  PTR vault.k28.com.
4   IN  PTR core.k28.com.
5   IN  PTR core.k28.com.
EOF

echo "=== Cek konfigurasi ==="
named-checkconf $CONF || exit 1
named-checkzone 3.225.192.in-addr.arpa /var/bind/3.225.192.in-addr.arpa || exit 1
named-checkzone 4.225.192.in-addr.arpa /var/bind/4.225.192.in-addr.arpa || exit 1

echo "=== Muat ulang named ==="
pkill named 2>/dev/null
sleep 1
named -u named
sleep 2

echo "=== Tes reverse di prab ==="
for ip in 192.225.3.2 192.225.3.3 192.225.4.2 192.225.4.4; do
    echo -n "$ip: "
    dig @192.225.5.2 -x $ip +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_prab.sh
/root/soal8_prab.sh
```

**`soal8_tedd.sh` (jalankan di tedd, setelah prab)**

```sh
cat > /root/soal8_tedd.sh <<'EOT'
#!/bin/sh
echo "=== Soal 8: reverse zone (tedd) ==="

CONF="/etc/bind/named.conf"

for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa; do
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

pkill named 2>/dev/null
sleep 1
named -u named
sleep 3

echo "=== File slave ==="
ls /var/bind/slave

echo "=== Cek authoritative (harus ada aa) ==="
for s in 192.225.5.3 192.225.5.2; do
    echo "--- server $s ---"
    for ip in 192.225.3.2 192.225.3.3 192.225.4.2 192.225.4.4; do
        dig @$s -x $ip | grep -E "flags: qr|PTR	" | grep -v "^;"
        dig @$s -x $ip | grep -E "^; *flags|^;; flags" | head -1
    done
done

echo "=== Serial SOA ==="
for z in 3.225.192.in-addr.arpa 4.225.192.in-addr.arpa; do
    dig @192.225.5.2 $z SOA +short
    dig @192.225.5.3 $z SOA +short
done
echo "=== Selesai ==="
EOT
chmod +x /root/soal8_tedd.sh
/root/soal8_tedd.sh
```

Catatan: jangan jalankan ulang `soal4_prab.sh` atau `soal4_tedd.sh` setelah soal 8, karena `named.conf` ditimpa dan deklarasi reverse zone hilang. Kalau terlanjur, jalankan `soal8_prab.sh` lalu `soal8_tedd.sh` untuk memasang kembali.
