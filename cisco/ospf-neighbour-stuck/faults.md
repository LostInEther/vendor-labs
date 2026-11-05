# Breaking the lab

Each fault starts from the working baseline. Apply the "break" commands, follow the blog post to diagnose it, then apply the "fix" commands before moving on.

Some faults don't take effect until the adjacency resets. Where a fault says to bounce an interface, use `shutdown` then `no shutdown`. Avoid `clear ip ospf process`, which asks for confirmation and resets every neighbour on the router.

To catch debug output, turn the debug on and wait at least one hello interval (10 seconds) before reading `show logging`. Turn it off with `undebug all`.

## 1. MTU mismatch

Break, on r2, then bounce r3's interface (the adjacency stays up until it resets):

```
interface Ethernet0/1
 ip mtu 1400
```

```
interface Ethernet0/0
 shutdown
 no shutdown
```

Fix, on r2:

```
interface Ethernet0/1
 no ip mtu
```

## 2. Area mismatch

Break, on r3:

```
interface Ethernet0/0
 ip ospf 1 area 0
```

Fix, on r3:

```
interface Ethernet0/0
 ip ospf 1 area 1
```

## 3. Hello and dead timer mismatch

Break, on r3 (the dead interval changes to 20 seconds automatically):

```
interface Ethernet0/0
 ip ospf hello-interval 5
```

Fix, on r3:

```
interface Ethernet0/0
 no ip ospf hello-interval
```

## 4. Authentication mismatch

Break, on r1 (authentication on one side only):

```
interface Ethernet0/0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 LabOnlyKey123
```

Then, for the second version of the fault, also on r2 with a different key:

```
interface Ethernet0/0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 LabOnlyKey124
```

Fix, on both r1 and r2:

```
interface Ethernet0/0
 no ip ospf authentication
 no ip ospf message-digest-key 1
```

## 5. Network type mismatch

Break, on r1:

```
interface Ethernet0/0
 ip ospf network point-to-point
```

Fix, on r1:

```
interface Ethernet0/0
 no ip ospf network point-to-point
```

## 6. Passive interface

Break, on r2:

```
router ospf 1
 passive-interface Ethernet0/1
```

Fix, on r2:

```
router ospf 1
 no passive-interface Ethernet0/1
```
