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