#!/bin/sh

echo "=== ApacheBench: www.k28.com ==="
ab -n 250 -c 10 http://www.k28.com/

echo ""
echo "=== ApacheBench: static.k28.com ==="
ab -n 250 -c 10 http://static.k28.com/

echo ""
echo "=== Soal 16 selesai ==="
