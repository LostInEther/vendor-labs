# EtherChannel not bundling

A two-switch lab for breaking an LACP EtherChannel five different ways and telling them apart from `show etherchannel summary`, the LACP neighbour table and the logs on each switch.

```
        e0/0 ============ e0/0
  sw1                            sw2
        e0/1 ============ e0/1
         Port-channel1 (LACP), trunking VLANs 10 and 20
```

| Device | Interface | Address | Purpose |
| --- | --- | --- | --- |
| sw1 | Ethernet0/0, Ethernet0/1 | | Members of Port-channel1 |
| sw1 | Vlan10 | 198.51.100.1/24 | Test address in VLAN 10 |
| sw1 | Vlan20 | 203.0.113.1/24 | Test address in VLAN 20 |
| sw2 | Ethernet0/0, Ethernet0/1 | | Members of Port-channel1 |
| sw2 | Vlan10 | 198.51.100.2/24 | Test address in VLAN 10 |
| sw2 | Vlan20 | 203.0.113.2/24 | Test address in VLAN 20 |

The addresses all come from documentation ranges (RFC 5737), so nothing clashes with a real network.

## Running it in CML

1. In CML, choose **Import** and select `etherchannel-not-bundling.yaml`.
2. Start the lab. The switches boot with their configs already applied.
3. Check the baseline on sw1:

```
show etherchannel summary
show interfaces trunk
ping 198.51.100.2
ping 203.0.113.2
```

Po1 should show `(SU)` with both members `(P)`, and both pings should work. The first ping of each usually loses one packet to ARP.

The lab uses two IOL-L2 switches (`ioll2-xe`), which CML 2.7 and later includes. CML Free allows five running nodes in total, so stop any other lab first. On another emulator (EVE-NG, GNS3) or another image, build two switches and paste the files from `configs/`, changing the interface names to match your image.

Two notes on the configs:

- They set `vtp mode transparent`. Without it, the switches boot in VTP server mode and ignore the `vlan` lines in the startup config, so VLANs 10 and 20 never exist and nothing passes over the trunk.
- They set `logging buffered 64000`, because IOL starts with a 4 KB log buffer.

## Blog post

The break and fix commands for each fault are in [faults.md](faults.md). How to diagnose each one is in the blog post: [Diagnosing an EtherChannel That Won't Bundle](https://josephoshaughnessy.hashnode.dev/etherchannel-not-bundling)
