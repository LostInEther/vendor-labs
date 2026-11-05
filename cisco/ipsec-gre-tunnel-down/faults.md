# Breaking the lab

Each fault starts from the working baseline. Apply the "break" commands, follow the blog post to diagnose it, then apply the "fix" commands before moving on.

In the lab, changing the IKEv2 proposal didn't touch the tunnel that was already up. It only failed at the next negotiation. So after each crypto change, force a new negotiation by bouncing Tunnel0 on the router you changed:

```
interface Tunnel0
 shutdown
 no shutdown
```

`clear crypto session` also works, and doesn't ask for confirmation. Avoid `clear logging`, which does.

To watch the negotiation, run `debug crypto ikev2` before the bounce, wait 10 to 15 seconds, then read `show logging` and turn it off with `undebug all`. After the fixes for faults 1 to 4, the tunnel came back by itself within about 10 seconds. After fault 5, give it up to a minute.

## 1. IKEv2 proposal mismatch

Break, on r2, then bounce Tunnel0:

```
crypto ikev2 proposal PROP
 no encryption aes-cbc-256
 encryption aes-cbc-128
```

Fix, on r2:

```
crypto ikev2 proposal PROP
 no encryption aes-cbc-128
 encryption aes-cbc-256
```

## 2. Pre-shared key mismatch

Break, on r2, then bounce Tunnel0:

```
crypto ikev2 keyring KR
 peer SITE-A
  pre-shared-key LabOnlyKey124
```

Fix, on r2:

```
crypto ikev2 keyring KR
 peer SITE-A
  pre-shared-key LabOnlyKey123
```

## 3. IPsec transform set mismatch

Break, on r2 (`esp-aes` with no key size means AES-128), then bounce Tunnel0:

```
crypto ipsec transform-set TS esp-aes esp-sha256-hmac
 mode transport
```

Fix, on r2:

```
crypto ipsec transform-set TS esp-aes 256 esp-sha256-hmac
 mode transport
```

## 4. ESP blocked in the path

Break, on inet (blocks ESP from r1 only, IKE on UDP 500 still gets through):

```
ip access-list extended FROM-R1
 deny esp any any
 permit ip any any
interface Ethernet0/0
 ip access-group FROM-R1 in
```

Fix, on inet:

```
interface Ethernet0/0
 no ip access-group FROM-R1 in
exit
no ip access-list extended FROM-R1
```

## 5. Recursive routing

Break, on r2 (a catch-all network statement pulls r2's public interface into OSPF, so r1 learns the route to the tunnel's own destination through the tunnel):

```
router ospf 1
 network 0.0.0.0 255.255.255.255 area 0
```

The tunnel goes down on r1 within a few seconds, comes back after a minute, then goes down again.

Fix, on r2:

```
router ospf 1
 no network 0.0.0.0 255.255.255.255 area 0
```
