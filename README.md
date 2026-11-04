# FortiGate: traffic not passing

One FortiGate between a client, a server and the internet, for breaking traffic through the firewall five ways: no matching policy, a deny above the allow, a reverse path check failure, a missing route and missing NAT.

The blog post that goes with it shows how to tell the faults apart with `diagnose debug flow`: [Why Isn't Traffic Passing Through My FortiGate?](https://josephoshaughnessy.hashnode.dev/fortigate-traffic-not-passing)

## Topology

| Node | Address | Connects to |
| --- | --- | --- |
| fgt02 port2 "LAN" | 198.51.100.1/24 | client01 eth1 (198.51.100.10) |
| fgt02 port1 "SERVERS" | 203.0.113.1/24 | srv01 eth1 (203.0.113.10), web server on port 80 |
| fgt02 port3 | DHCP | CML NAT connector (internet) |

CML's interfaces p1 to p3 are FortiOS's port1 to port3. All the LAN and server addresses come from documentation ranges (RFC 5737), so nothing clashes with a real network.

Firewall policies in the baseline:

- **1 `LAN-to-SERVERS`**: port2 to port1, all services, accept, no NAT
- **2 `LAN-to-Internet`**: port2 to port3, all services, accept, NAT enabled

## Files

- `fortigate-traffic-not-passing.yaml`: the CML topology, ready to import. client01 and srv01 boot with their addresses already set.
- `configs/fgt02.txt`: the FortiGate baseline config, to paste in once it's licensed.
- `configs/client01-boot.sh`, `configs/srv01-boot.sh`: the Linux nodes' startup scripts, if you're building this in another emulator.
- `faults.md`: the commands to break and fix each fault in the post.

## Requirements

- [Cisco Modeling Labs](https://developer.cisco.com/modeling-labs/). Built and tested on CML 2.9.
- A FortiGate-VM KVM image added to CML as a node definition called `fortigate`. The lab was tested on FortiOS 7.4.13. Fortinet doesn't ship FortiGate with CML, so you'll need to download the image and add it yourself.
- A FortiGate-VM licence. Fortinet's free [permanent trial licence](https://docs.fortinet.com/document/fortigate/7.4.6/administration-guide/441460) is enough. It's limited to 1 CPU and 2 GB of RAM, and to a small number of interfaces, policies and routes. In this lab FortiOS only showed port1 to port3, which is why the servers are on port1.
- The `net-tools` nodes, which came with CML 2.9.

## Setup

1. In CML, choose **Import** and select `fortigate-traffic-not-passing.yaml`. If your FortiGate node definition has a different name, change `node_definition: fortigate` in the file first.
2. Start the lab.
3. Log in to fgt02's console and activate the licence.
4. Paste in `configs/fgt02.txt`.
5. Test from client01's console:

```
ping -c 3 203.0.113.10
curl http://203.0.113.10
ping -c 3 1.1.1.1
```

You should get replies to both pings and `hello from srv01` from the curl. That's the working baseline.

## Shutting down

Run `execute shutdown` on fgt02's console before you stop the lab. Stopping a FortiGate without shutting it down first can leave its disk needing a check at the next boot.

## Optional: running commands on fgt02 with pyATS

CML's pyATS automation has no FortiGate plugin, and the default plugins don't recognise FortiOS's `hostname # ` prompt, so automated commands hang after logging in. In this lab, setting the fortigate node definition's PyATS operating system to `cimc` worked for both show commands and config blocks. That's a workaround, not something Fortinet or Cisco support.
