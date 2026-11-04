ip address add 203.0.113.10/24 dev eth1
ip link set dev eth1 up
ip route replace default via 203.0.113.1 dev eth1
mkdir -p /tmp/www && echo "hello from srv01" > /tmp/www/index.html
(busybox httpd -p 80 -h /tmp/www || python3 -m http.server 80 -d /tmp/www) >/dev/null 2>&1 &
echo "READY" >/dev/console
exit 0
