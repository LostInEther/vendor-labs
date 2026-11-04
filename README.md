# vendor-labs

Lab topologies and configs from my networking blog, [josephoshaughnessy.hashnode.dev](https://josephoshaughnessy.hashnode.dev).

These labs run on vendor images in an emulator, unlike the single-machine Linux labs in [network-labs](https://github.com/LostInEther/network-labs). Each lab includes:

- a CML topology file (`.yaml`), ready to import
- each device's config as plain text in `configs/`, for EVE-NG, GNS3 or real kit
- `faults.md`, with the commands to break and fix each fault in the post

## Requirements

- [Cisco Modeling Labs](https://developer.cisco.com/modeling-labs/) 2.7 or later. CML Free is enough for the Cisco labs, which use the IOL-XE images included with it, and the Cisco topology files have the device configs already in them.
- The Fortinet labs also need your own FortiGate-VM image and licence, because Fortinet doesn't ship FortiGate with CML. Fortinet's free permanent trial licence is enough. You paste the FortiGate config in once it's licensed. Each lab's README has the details.
- Or any emulator that runs the same images, using the configs in each lab's `configs/` folder.

## Labs

| Lab | What it covers | Blog post |
| --- | --- | --- |
| [cisco/bgp-session-down](cisco/bgp-session-down/) | Three IOL-XE routers with eBGP and iBGP, for breaking a BGP session five ways: an ACL on TCP 179, a missing update-source, missing eBGP multihop, an AS typo and an MD5 password | [Diagnosing BGP Sessions That Won't Come Up](https://josephoshaughnessy.hashnode.dev/bgp-session-wont-come-up) |
| [fortinet/fortigate-traffic-not-passing](fortinet/fortigate-traffic-not-passing/) | A FortiGate between a client, a server and the internet, for breaking traffic through the firewall five ways: no matching policy, a deny above the allow, a reverse path check failure, a missing route and missing NAT | [Why Isn't Traffic Passing Through My FortiGate?](https://josephoshaughnessy.hashnode.dev/fortigate-traffic-not-passing) |

The lab networks and AS numbers come from documentation ranges (RFC 5737 and RFC 5398), so nothing clashes with a real network. The exceptions are the address CML's NAT connector hands out, and the 10.99.0.0/24 "new subnet" in the FortiGate lab's reverse path fault.
