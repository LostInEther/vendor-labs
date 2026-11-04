ip address add 198.51.100.10/24 dev eth1
ip link set dev eth1 up
ip route replace default via 198.51.100.1 dev eth1
echo "READY" >/dev/console
exit 0
