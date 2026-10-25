# BGP session down

A three-router lab for breaking a BGP session five different ways and telling them apart from `show` output, logs and packet captures.

```
cust01 (AS 64511) --- pe01 (AS 64500) --- pe02 (AS 64500)
        eBGP on the link       iBGP between loopbacks, over OSPF
```

| Device | Interface | Address | Purpose |
| --- | --- | --- | --- |
| cust01 | Ethernet0/0 | 198.51.100.2/30 | Link to pe01 |
| cust01 | Loopback0 | 203.0.113.1/24 | Customer LAN, advertised in BGP |
| pe01 | Ethernet0/0 | 198.51.100.1/30 | Link to cust01 |
| pe01 | Ethernet0/1 | 192.0.2.1/30 | Link to pe02 |
| pe01 | Loopback0 | 192.0.2.11/32 | iBGP peering address |
| pe02 | Ethernet0/0 | 192.0.2.2/30 | Link to pe01 |
| pe02 | Loopback0 | 192.0.2.12/32 | iBGP peering address |
| pe02 | Loopback1 | 198.51.100.129/25 | Provider routes, advertised in BGP |

The addresses and AS numbers all come from documentation ranges (RFC 5737 and RFC 5398), so nothing clashes with a real network.

## Running it in CML

1. In CML, choose **Import** and select `bgp-session-down.yaml`.
2. Start the lab. The routers boot with their configs already applied.
3. Check the baseline on cust01:

```
show ip bgp summary
show ip route bgp
ping 198.51.100.129 source 203.0.113.1
```

Both BGP sessions should be up, and cust01 should have a route to 198.51.100.128/25.

The lab uses the IOL-XE node type, which CML 2.7 and later includes. On another emulator (EVE-NG, GNS3) or another image, build three routers and paste the files from `configs/`, changing the interface names to match your image.

## Blog post

The break and fix commands for each fault are in [faults.md](faults.md). How to diagnose each one is in the blog post: [Diagnosing BGP Sessions That Won't Come Up](https://josephoshaughnessy.hashnode.dev/bgp-session-wont-come-up)
