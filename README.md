# vendor-labs

Lab topologies and configs from my networking blog, [josephoshaughnessy.hashnode.dev](https://josephoshaughnessy.hashnode.dev).

These labs run on vendor images in an emulator, unlike the single-machine Linux labs in [network-labs](https://github.com/LostInEther/network-labs). Each lab includes:

- a CML topology file (`.yaml`) with the device configs already in it, ready to import
- each device's config as plain text in `configs/`, for EVE-NG, GNS3 or real kit
- `faults.md`, with the commands to break and fix each fault in the post

## Requirements

- [Cisco Modeling Labs](https://developer.cisco.com/modeling-labs/) 2.7 or later. CML Free is enough for the Cisco labs, which use the IOL-XE images included with it.
- Or any emulator that runs the same images, using the configs in each lab's `configs/` folder.

## Labs

| Lab | What it covers | Blog post |
| --- | --- | --- |
| [cisco/bgp-session-down](cisco/bgp-session-down/) | Three IOL-XE routers with eBGP and iBGP, for breaking a BGP session five ways: an ACL on TCP 179, a missing update-source, missing eBGP multihop, an AS typo and an MD5 password | [Diagnosing BGP Sessions That Won't Come Up](https://josephoshaughnessy.hashnode.dev/bgp-session-wont-come-up) |

All addresses and AS numbers come from documentation ranges (RFC 5737 and RFC 5398), so nothing clashes with a real network.
