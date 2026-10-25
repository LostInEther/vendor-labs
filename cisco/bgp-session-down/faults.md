# Breaking the lab

Each fault starts from the working baseline. Apply the "break" commands, follow the blog post to diagnose it, then apply the "fix" commands before moving on.

## 1. ACL blocking TCP 179

Break, on pe01:

```
ip access-list extended CUST01-IN
 deny tcp any any eq bgp
 deny tcp any eq bgp any
 permit ip any any
interface Ethernet0/0
 ip access-group CUST01-IN in
end
clear ip bgp 198.51.100.2
```

To make the ACL drop silently instead of rejecting, also add `no ip unreachables` under `interface Ethernet0/0`.

Fix, on pe01:

```
interface Ethernet0/0
 no ip access-group CUST01-IN in
 ip unreachables
exit
no ip access-list extended CUST01-IN
```

## 2. iBGP without update-source

Break, on pe02 (the session stays up), then on pe01 as well (now it breaks):

```
router bgp 64500
 no neighbor 192.0.2.11 update-source Loopback0
end
clear ip bgp 192.0.2.11
```

```
router bgp 64500
 no neighbor 192.0.2.12 update-source Loopback0
end
clear ip bgp 192.0.2.12
```

Fix: put `neighbor ... update-source Loopback0` back on both.

## 3. eBGP between loopbacks without multihop

Break, on cust01:

```
ip route 192.0.2.11 255.255.255.255 198.51.100.1
router bgp 64511
 no neighbor 198.51.100.1
 neighbor 192.0.2.11 remote-as 64500
 neighbor 192.0.2.11 update-source Loopback0
 address-family ipv4
  neighbor 192.0.2.11 activate
```

On pe01:

```
ip route 203.0.113.1 255.255.255.255 198.51.100.2
router bgp 64500
 no neighbor 198.51.100.2
 neighbor 203.0.113.1 remote-as 64511
 neighbor 203.0.113.1 update-source Loopback0
 address-family ipv4
  neighbor 203.0.113.1 activate
```

Fix: add `neighbor ... ebgp-multihop 2` on both sides. To return to the baseline afterwards, remove the loopback neighbours and static routes, and put the original link peering back.

## 4. Remote AS typo

Break, on pe01:

```
router bgp 64500
 no neighbor 198.51.100.2
 neighbor 198.51.100.2 remote-as 64510
 address-family ipv4
  neighbor 198.51.100.2 activate
```

Fix: the same commands with `remote-as 64511`.

## 5. MD5 password

Break, on pe01, while the session is up. Then reset it:

```
router bgp 64500
 neighbor 198.51.100.2 password LabSecret1
end
clear ip bgp 198.51.100.2
```

For a mismatch rather than a missing password, also set `neighbor 198.51.100.1 password LabSecret2` on cust01.

Fix: `no neighbor ... password` on both sides, then `clear ip bgp`.
