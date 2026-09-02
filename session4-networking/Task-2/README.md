# Task 2: Networking Commands & Analysis

This document records essential Linux networking commands executed in `session4-networking`, along with their outputs and concise 2-3 line summaries.

---

## 1. `ip a`

### Command Output
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether dc:97:ba:23:7a:85 brd ff:ff:ff:ff:ff:ff
    inet 100.129.162.126/20 brd 100.129.175.255 scope global dynamic noprefixroute wlp0s20f3
       valid_lft 82054sec preferred_lft 82054sec
    inet6 fe80::6a2c:e2a4:333c:1d96/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether f2:30:65:48:9a:18 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
4: br-3bacb36baed6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 82:b5:7c:1d:7c:54 brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-3bacb36baed6
       valid_lft forever preferred_lft forever
    inet6 fe80::80b5:7cff:fe1d:7c54/64 scope link
       valid_lft forever preferred_lft forever
```

### Explanation
The `ip a` command displays network interfaces, assigned IPv4/IPv6 addresses, MAC addresses, and operational status (UP/DOWN). It shows local loopback (`127.0.0.1`), active Wi-Fi connection (`100.129.162.126`), and Docker bridge network interfaces. This is the primary tool for verifying network interface configuration on Linux hosts.

---

## 2. `ping -c 4 google.com`

### Command Output
```text
PING google.com (142.250.205.206) 56(84) bytes of data.
64 bytes from lcboma-ba-in-f14.1e100.net (142.250.205.206): icmp_seq=1 ttl=117 time=39.3 ms
64 bytes from lcboma-ba-in-f14.1e100.net (142.250.205.206): icmp_seq=2 ttl=117 time=32.3 ms
64 bytes from lcboma-ba-in-f14.1e100.net (142.250.205.206): icmp_seq=3 ttl=117 time=42.1 ms
64 bytes from lcboma-ba-in-f14.1e100.net (142.250.205.206): icmp_seq=4 ttl=117 time=109 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 7095ms
rtt min/avg/max/mdev = 32.314/55.678/109.009/30.995 ms
```

### Explanation
The `ping` command sends ICMP Echo Request packets to test network reachability and measure round-trip latency to a target host. Receiving 4 reply packets with 0% packet loss confirms active internet connection to `google.com`. It serves as the basic diagnostic tool for host-to-host connectivity.

---

## 3. `nslookup google.com`

### Command Output
```text
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.205.206
Name:   google.com
Address: 2404:6800:4009:81e::200e
```

### Explanation
The `nslookup` command queries DNS server records to translate human-readable domain names into IP addresses. It used local resolver `127.0.0.53` to resolve `google.com` to IPv4 `142.250.205.206` and IPv6 `2404:6800:4009:81e::200e`. This helps verify DNS resolution and troubleshoot domain name issues.

---

## 4. `tracepath google.com`

### Command Output
```text
 1?: [LOCALHOST]                      pmtu 1500
 1:  wifi.height8tech.com                                 10.098ms
 2:  202.131.133.5.convergentindia.com                   330.676ms
 3:  115.117.125.189.static-mumbai.vsnl.net.in             7.628ms
 4:  172.28.117.90                                        32.131ms asymm  5
 5:  115.112.15.114.static-chennai.vsnl.net.in            46.125ms asymm 10
     Too many hops: pmtu 1500
     Resume: pmtu 1500
```

### Explanation
The `tracepath` command traces network packet routing paths to a destination while discovering the Path MTU along each hop. It lists intermediate gateway routers and hop latencies between source host and target. This helps pinpoint network routing delays and packet drop locations.

---

## 5. `ss -tuln`

### Command Output
```text
Netid  State   Recv-Q  Send-Q   Local Address:Port    Peer Address:Port Process
udp    UNCONN  0       0          224.0.0.251:5353         0.0.0.0:*
udp    UNCONN  0       0           127.0.0.53%lo:53         0.0.0.0:*
tcp    LISTEN  0       151          127.0.0.1:3306         0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:5432         0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:6379         0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:8080         0.0.0.0:*
tcp    LISTEN  0       4096           0.0.0.0:8081         0.0.0.0:*
tcp    LISTEN  0       511                  *:80                 *:*
```

### Explanation
The `ss -tuln` command dumps socket statistics, displaying listening TCP (`-t`) and UDP (`-u`) ports in numeric format (`-n`). It confirms open network ports such as HTTP (80), MySQL (3306), PostgreSQL (5432), and Redis (6379). This allows inspecting listening services and verifying socket states.

---

## 6. `curl -I https://google.com`

### Command Output
```text
HTTP/2 301
location: https://www.google.com/
content-type: text/html; charset=UTF-8
date: Wed, 02 Sep 2026 17:01:20 GMT
expires: Fri, 02 Oct 2026 17:01:20 GMT
cache-control: public, max-age=2592000
server: gws
content-length: 220
x-xss-protection: 0
x-frame-options: SAMEORIGIN
```

### Explanation
The `curl -I` command fetches HTTP response headers from a target URL without downloading the response body. It reveals HTTP status code 301 (Moved Permanently), server details (`gws`), and header metadata. This is used to test web service connectivity and inspect HTTP headers.

---

## 7. `hostname -I`

### Command Output
```text
100.129.162.126 172.17.0.1 172.19.0.1
```

### Explanation
The `hostname -I` command displays all network IP addresses assigned to the local host interface cards. It lists the main active network IP address (`100.129.162.126`) alongside Docker virtual bridge IPs (`172.17.0.1`, `172.19.0.1`). It provides a quick way to retrieve machine network IP addresses.
