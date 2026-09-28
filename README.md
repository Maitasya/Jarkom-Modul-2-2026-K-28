# Jarkom-Modul-2-2026-K-28
## Kelompok K-28

| Nama | NRP |
| :---: | :---: |
| Maitasya Rohmatul Ula | 5027251026 |
| A. Algifari Rantiga Isdar | 5027251084 |

---
# Soal 1 — Konfigurasi IP Address dan Default Gateway

## Tujuan

Melakukan konfigurasi alamat IP dan default gateway pada seluruh node *The Mesh* sesuai dengan pembagian jaringan pada topologi. Setiap kelompok menggunakan prefix `192.225.x.x`, sedangkan `rootkit` berperan sebagai router/gateway utama yang menghubungkan seluruh jaringan internal.

<img width="959" height="415" alt="image" src="https://github.com/user-attachments/assets/6de7ff0a-14f3-425f-a54d-55c880b5ca2b" />

## Tabel Konfigurasi IP
| No | Node    | Interface | IP Address     | Default Gateway |
| -: | ------- | --------- | -------------- | --------------- |
|  1 | rootkit | eth1      | 192.225.1.1/24 | -               |
|  2 | rootkit | eth2      | 192.225.2.1/24 | -               |
|  3 | rootkit | eth3      | 192.225.3.1/24 | -               |
|  4 | rootkit | eth4      | 192.225.4.1/24 | -               |
|  5 | rootkit | eth5      | 192.225.5.1/24 | -               |
|  6 | alpha   | eth0      | 192.225.1.2/24 | 192.225.1.1     |
|  7 | beta    | eth0      | 192.225.1.3/24 | 192.225.1.1     |
|  8 | gamma   | eth0      | 192.225.1.4/24 | 192.225.1.1     |
|  9 | delta   | eth0      | 192.225.2.2/24 | 192.225.2.1     |
| 10 | epsilon | eth0      | 192.225.2.3/24 | 192.225.2.1     |
| 11 | abbey   | eth0      | 192.225.3.2/24 | 192.225.3.1     |
| 12 | penny   | eth0      | 192.225.3.3/24 | 192.225.3.1     |
| 13 | obladi  | eth0      | 192.225.4.2/24 | 192.225.4.1     |
| 14 | desmond | eth0      | 192.225.4.3/24 | 192.225.4.1     |
| 15 | oblada  | eth0      | 192.225.4.4/24 | 192.225.4.1     |
| 16 | molly   | eth0      | 192.225.4.5/24 | 192.225.4.1     |
| 17 | prab    | eth0      | 192.225.5.2/24 | 192.225.5.1     |
| 18 | tedd    | eth0      | 192.225.5.3/24 | 192.225.5.1      |

## 1. Konfigurasi IP Address dan Default Gateway

Pada tahap ini dilakukan konfigurasi IP Address dan Default Gateway pada seluruh node berdasarkan pembagian jaringan pada masing-masing switch.

### Konfigurasi Rootkit

Konfigurasi pada file `/etc/network/interfaces`:

```text
auto eth1
iface eth1 inet static
    address 192.225.5.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.225.4.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.225.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.225.1.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.225.2.1
    netmask 255.255.255.0
````

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

### Konfigurasi Penny

```text
auto eth0
iface eth0 inet static
    address 192.225.3.2
    netmask 255.255.255.0
    gateway 192.225.3.1
```

### Konfigurasi Abbey

```text
auto eth0
iface eth0 inet static
    address 192.225.4.2
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

### Konfigurasi Obladi

```text
auto eth0
iface eth0 inet static
    address 192.225.5.4
    netmask 255.255.255.0
    gateway 192.225.5.1
```

### Konfigurasi Desmond

```text
auto eth0
iface eth0 inet static
    address 192.225.5.5
    netmask 255.255.255.0
    gateway 192.225.5.1
```

### Konfigurasi Oblada

```text
auto eth0
iface eth0 inet static
    address 192.225.5.6
    netmask 255.255.255.0
    gateway 192.225.5.1
```

### Konfigurasi Molly

```text
auto eth0
iface eth0 inet static
    address 192.225.5.7
    netmask 255.255.255.0
    gateway 192.225.5.1
```



## Verifikasi

Setelah konfigurasi dilakukan, setiap node diperiksa menggunakan:

```bash
ip addr
```

untuk memastikan alamat IP telah sesuai.

Default gateway diperiksa menggunakan:

```bash
ip route
```
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

Pada node lainnya, nama script disesuaikan dengan nama node.

Hasil dari setiap script digunakan untuk memastikan konfigurasi dan konektivitas seluruh node telah berjalan sesuai topologi.



