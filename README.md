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
| 18 | tedd    | eth0      | 192.225.5.3/24 | 192.225.5.      |


## Konfigurasi Rootkit

Node `rootkit` berfungsi sebagai router utama yang menghubungkan lima jaringan internal. Setiap interface internal diberikan alamat gateway pertama pada subnet masing-masing.

| Interface | Network        | IP Rootkit  | Fungsi                              |
| --------- | -------------- | ----------- | ----------------------------------- |
| eth1      | 192.225.1.0/24 | 192.225.1.1 | Gateway jaringan alpha, beta, gamma |
| eth2      | 192.225.2.0/24 | 192.225.2.1 | Gateway jaringan delta, epsilon     |
| eth3      | 192.225.3.0/24 | 192.225.3.1 | Gateway jaringan abbey, penny       |
| eth4      | 192.225.4.0/24 | 192.225.4.1 | Gateway jaringan repository         |
| eth5      | 192.225.5.0/24 | 192.225.5.1 | Gateway jaringan DNS                |

Interface WAN pada `rootkit` digunakan sebagai jalur menuju jaringan luar/NAT.

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



