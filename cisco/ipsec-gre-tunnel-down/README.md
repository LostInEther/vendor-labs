# IPsec GRE tunnel down

A three-router lab for breaking a GRE over IPsec tunnel five different ways and telling them apart from `show crypto session`, the IPsec counters, the logs and `debug crypto ikev2`.

```
 r1 ------------- inet ------------- r2
 site A         "internet"        site B
   \________ Tunnel0 (GRE over IPsec, IKEv2) ________/
               OSPF runs over the tunnel
```

| Device | Interface | Address | Purpose |
| --- | --- | --- | --- |
| r1 | Ethernet0/0 | 192.0.2.2/30 | Public address, link to inet |
| r1 | Tunnel0 | 198.51.100.1/30 | GRE over IPsec to r2 |
| r1 | Loopback1 | 203.0.113.1/25 | Site A LAN |
| inet | Ethernet0/0 | 192.0.2.1/30 | Link to r1 |
| inet | Ethernet0/1 | 192.0.2.5/30 | Link to r2 |
| r2 | Ethernet0/0 | 192.0.2.6/30 | Public address, link to inet |
| r2 | Tunnel0 | 198.51.100.2/30 | GRE over IPsec to r1 |
| r2 | Loopback1 | 203.0.113.129/25 | Site B LAN |

- **IKEv2:** AES-CBC-256, SHA-256, DH group 14, pre-shared key.
- **IPsec:** ESP AES-256 with SHA-256, transport mode, applied with `tunnel protection`.
- **Routing:** r1 and r2 each have a static default route to inet, and run OSPF only on the tunnel and their LAN. inet doesn't run OSPF and knows nothing about the LANs, like a real internet provider.

The addresses all come from documentation ranges (RFC 5737), so nothing clashes with a real network. The pre-shared key is for this lab only.

## Running it in CML

1. In CML, choose **Import** and select `ipsec-gre-tunnel-down.yaml`.
2. Start the lab. The routers boot with their configs already applied.
3. Check the baseline on r1:

```
show crypto session
show ip ospf neighbor
show ip route ospf
ping 203.0.113.129 source 203.0.113.1
```

The session should be `UP-ACTIVE`, r2 should be a FULL OSPF neighbour on Tunnel0, and the ping from site A's LAN to site B's should work.

The lab uses three IOL-XE routers, which CML 2.7 and later includes. CML Free allows five running nodes in total, so stop any other lab first. On another emulator (EVE-NG, GNS3) or another image, build three routers and paste the files from `configs/`, changing the interface names to match your image.

The configs set `logging buffered 64000`, because IOL starts with a 4 KB log buffer and `debug crypto ikev2` fills that in seconds.

## Blog post

The break and fix commands for each fault are in [faults.md](faults.md). How to diagnose each one is in the blog post: [Diagnosing an IPsec Tunnel That Won't Come Up](https://josephoshaughnessy.hashnode.dev/ipsec-gre-tunnel-down)
