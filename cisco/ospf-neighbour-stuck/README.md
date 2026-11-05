# OSPF neighbour stuck

A three-router lab for breaking an OSPF adjacency six different ways and telling them apart from `show` output, logs and counters.

```
r1 ------------ r2 ------------ r3
      area 0          area 1
                 (r2 is the ABR)
```

| Device | Interface | Address | Purpose |
| --- | --- | --- | --- |
| r1 | Ethernet0/0 | 198.51.100.1/30 | Link to r2, area 0 |
| r1 | Loopback0 | 192.0.2.1/32 | Router ID, area 0 |
| r2 | Ethernet0/0 | 198.51.100.2/30 | Link to r1, area 0 |
| r2 | Ethernet0/1 | 198.51.100.5/30 | Link to r3, area 1 |
| r2 | Loopback0 | 192.0.2.2/32 | Router ID, area 0 |
| r3 | Ethernet0/0 | 198.51.100.6/30 | Link to r2, area 1 |
| r3 | Loopback0 | 192.0.2.3/32 | Router ID, area 1 |
| r3 | Loopback1 | 203.0.113.1/24 | Branch LAN, area 1 |

The addresses all come from documentation ranges (RFC 5737), so nothing clashes with a real network.

## Running it in CML

1. In CML, choose **Import** and select `ospf-neighbour-stuck.yaml`.
2. Start the lab. The routers boot with their configs already applied.
3. Check the baseline on r1:

```
show ip ospf neighbor
show ip route ospf
ping 203.0.113.1 source 192.0.2.1
```

r1 should be FULL with r2, and have routes to r3's loopback and 203.0.113.0/24 as `O IA` (inter-area).

The lab uses three IOL-XE routers, which CML 2.7 and later includes. CML Free allows five running nodes in total, so stop any other lab first. On another emulator (EVE-NG, GNS3) or another image, build three routers and paste the files from `configs/`, changing the interface names to match your image.

The configs set `logging buffered 64000`. IOL-XE starts with a 4 KB log buffer, which is too small to keep debug output.

## Blog post

The break and fix commands for each fault are in [faults.md](faults.md). How to diagnose each one is in the blog post: [Diagnosing OSPF Neighbours That Won't Come Up](https://josephoshaughnessy.hashnode.dev/ospf-neighbour-wont-come-up)
