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

## Tabel Konfigurasi IP

| No | Node    | Interface | IP Address       | Default Gateway |
| -: | ------- | --------- | ---------------- | --------------- |
|  1 | rootkit | eth1      | `192.225.1.1/24` | -               |
|  2 | rootkit | eth2      | `192.225.2.1/24` | -               |
|  3 | rootkit | eth3      | `192.225.3.1/24` | -               |
|  4 | rootkit | eth4      | `192.225.4.1/24` | -               |
|  5 | rootkit | eth5      | `192.225.5.1/24` | -               |
|  6 | alpha   | eth0      | `192.225.1.2/24` | `192.225.1.1`   |
|  7 | beta    | eth0      | `192.225.1.3/24` | `192.225.1.1`   |
|  8 | gamma   | eth0      | `192.225.1.4/24` | `192.225.1.1`   |
|  9 | delta   | eth0      | `192.225.2.2/24` | `192.225.2.1`   |
| 10 | epsilon | eth0      | `192.225.2.3/24` | `192.225.2.1`   |
| 11 | abbey   | eth0      | `192.225.3.2/24` | `192.225.3.1`   |
| 12 | penny   | eth0      | `192.225.3.3/24` | `192.225.3.1`   |
| 13 | obladi  | eth0      | `192.225.4.2/24` | `192.225.4.1`   |
| 14 | desmond | eth0      | `192.225.4.3/24` | `192.225.4.1`   |
| 15 | oblada  | eth0      | `192.225.4.4/24` | `192.225.4.1`   |
| 16 | molly   | eth0      | `192.225.4.5/24` | `192.225.4.1`   |
| 17 | prab    | eth0      | `192.225.5.2/24` | `192.225.5.1`   |
| 18 | tedd    | eth0      | `192.225.5.3/24` | `192.225.5.1`   |

## Konfigurasi IP Address dan Default Gateway

Pada tahap ini dilakukan konfigurasi IP Address dan Default Gateway pada seluruh node berdasarkan pembagian jaringan pada masing-masing switch.

### Konfigurasi Rootkit

Konfigurasi pada file `/etc/network/interfaces`:

```text
auto eth1
iface eth1 inet static
    address 192.225.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.225.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.225.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.225.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.225.5.1
    netmask 255.255.255.0
```

### Konfigurasi Alpha

```text
auto eth0
iface eth0 inet static
    address 192.225.1.2
    netmask 255.255.255.0
    gateway 192.225.1.1
```

### Konfigurasi Beta

```text
auto eth0
iface eth0 inet static
    address 192.225.1.3
    netmask 255.255.255.0
    gateway 192.225.1.1
```

### Konfigurasi Gamma

```text
auto eth0
iface eth0 inet static
    address 192.225.1.4
    netmask 255.255.255.0
    gateway 192.225.1.1
```

### Konfigurasi Delta

```text
auto eth0
iface eth0 inet static
    address 192.225.2.2
    netmask 255.255.255.0
    gateway 192.225.2.1
```

### Konfigurasi Epsilon

```text
auto eth0
iface eth0 inet static
    address 192.225.2.3
    netmask 255.255.255.0
    gateway 192.225.2.1
```

### Konfigurasi Abbey

```text
auto eth0
iface eth0 inet static
    address 192.225.3.2
    netmask 255.255.255.0
    gateway 192.225.3.1
```

### Konfigurasi Penny

```text
auto eth0
iface eth0 inet static
    address 192.225.3.3
    netmask 255.255.255.0
    gateway 192.225.3.1
```

### Konfigurasi Obladi

```text
auto eth0
iface eth0 inet static
    address 192.225.4.2
    netmask 255.255.255.0
    gateway 192.225.4.1
```

### Konfigurasi Desmond

```text
auto eth0
iface eth0 inet static
    address 192.225.4.3
    netmask 255.255.255.0
    gateway 192.225.4.1
```

### Konfigurasi Oblada

```text
auto eth0
iface eth0 inet static
    address 192.225.4.4
    netmask 255.255.255.0
    gateway 192.225.4.1
```

### Konfigurasi Molly

```text
auto eth0
iface eth0 inet static
    address 192.225.4.5
    netmask 255.255.255.0
    gateway 192.225.4.1
```

### Konfigurasi Prab

```text
auto eth0
iface eth0 inet static
    address 192.225.5.2
    netmask 255.255.255.0
    gateway 192.225.5.1
```

### Konfigurasi Tedd

```text
auto eth0
iface eth0 inet static
    address 192.225.5.3
    netmask 255.255.255.0
    gateway 192.225.5.1
```

## Verifikasi

Setelah konfigurasi dilakukan, konfigurasi IP pada setiap node diperiksa menggunakan:

```bash
ip addr
```

untuk memastikan alamat IP telah sesuai.

Default gateway dan routing diperiksa menggunakan:

```bash
ip route
```

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
# Soal 4 — Konfigurasi DNS Master dan Slave

## Tujuan

Membangun DNS authoritative pada `prab` sebagai DNS Master dan `tedd` sebagai DNS Slave untuk zona `k28.com`. Zona memiliki SOA, NS record, A record untuk `prab` dan `tedd`, serta A record apex `k28.com` yang mengarah ke `penny`.

## 1. Instalasi BIND

Instalasi dilakukan pada node **prab** dan **tedd** menggunakan Alpine Linux.

```bash
apk update
apk add bind bind-tools
```

Kemudian service BIND diaktifkan:

```bash
rc-update add named
service named start
```

## 2. Konfigurasi DNS Master pada Prab

Pada node **prab**, file `/etc/bind/named.conf` dikonfigurasi dengan zona `k28.com`:

```text
zone "k28.com" {
    type master;
    file "/etc/bind/zones/k28.com";
    notify yes;
    allow-transfer { 192.225.5.3; };
    also-notify { 192.225.5.3; };
};
```

## 3. Zone File pada Prab

Direktori zona dibuat dengan:

```bash
mkdir -p /etc/bind/zones
```

Kemudian file `/etc/bind/zones/k28.com` dibuat dengan isi:

```text
$TTL 86400
@   IN  SOA prab.k28.com. admin.k28.com. (
        2026092801
        3600
        1800
        604800
        86400
)

@       IN  NS  prab.k28.com.
@       IN  NS  tedd.k28.com.

prab    IN  A   192.225.5.2
tedd    IN  A   192.225.5.3

@       IN  A   192.225.3.3
```

Dengan konfigurasi tersebut:

* `prab.k28.com` → `192.225.5.2`
* `tedd.k28.com` → `192.225.5.3`
* `k28.com` → `192.225.3.3` (`penny`)

## 4. Konfigurasi Forwarder pada Prab

Pada bagian `options` di `/etc/bind/named.conf` ditambahkan:

```text
options {
    directory "/var/bind";

    listen-on { any; };
    listen-on-v6 { none; };

    allow-query { any; };

    forwarders {
        192.168.122.1;
    };

    recursion yes;
};
```

Forwarder digunakan untuk meneruskan query DNS yang tidak berasal dari zona `k28.com` ke `192.168.122.1`.

## 5. Verifikasi DNS Master

Pada node **prab**, konfigurasi diperiksa menggunakan:

```bash
named-checkconf
```

Kemudian zone diperiksa:

```bash
named-checkzone k28.com /etc/bind/zones/k28.com
```

Setelah konfigurasi dinyatakan benar, service BIND dijalankan ulang:

```bash
service named restart
```

## 6. Konfigurasi DNS Slave pada Tedd

Pada node **tedd**, file `/etc/bind/named.conf` dikonfigurasi:

```text
zone "k28.com" {
    type slave;
    masters { 192.225.5.2; };
    file "/var/bind/k28.com";
};
```

Kemudian service BIND dijalankan ulang:

```bash
service named restart
```

Zona diperiksa untuk memastikan proses zone transfer dari `prab` berhasil:

```bash
ls -l /var/bind/
```

## 7. Konfigurasi Resolver pada Entitas Non-Router

Pada seluruh node selain `rootkit`, file `/etc/resolv.conf` diperbarui menjadi:

```text
nameserver 192.225.5.2
nameserver 192.225.5.3
nameserver 192.168.122.1
```

Urutan resolver adalah `prab`, kemudian `tedd`, dan terakhir `192.168.122.1`.

## 8. Verifikasi DNS

Pengujian dilakukan untuk memastikan DNS Master dan Slave dapat menjawab query.

Query ke Master:

```bash
nslookup k28.com 192.225.5.2
```

Query ke Slave:

```bash
nslookup k28.com 192.225.5.3
```

Pengujian hostname `prab`:

```bash
nslookup prab.k28.com 192.225.5.2
```

Pengujian hostname `tedd`:

```bash
nslookup tedd.k28.com 192.225.5.2
```

Pengujian dari Slave:

```bash
nslookup k28.com 192.225.5.3
```

Hasil yang diharapkan:

```text
k28.com        → 192.225.3.3
prab.k28.com   → 192.225.5.2
tedd.k28.com   → 192.225.5.3
```

Dengan demikian, `prab` berfungsi sebagai DNS Master authoritative dan `tedd` sebagai DNS Slave authoritative untuk zona `k28.com`.


