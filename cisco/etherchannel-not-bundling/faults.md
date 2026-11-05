# Breaking the lab

Each fault starts from the working baseline. Apply the "break" commands, follow the blog post to diagnose it, then apply the "fix" commands before moving on.

To change a port from LACP to another mode (`on`, or PAgP's `desirable`), IOS needs the old channel-group removed first, so those faults start with `no channel-group`.

## 1. LACP passive on both sides

Break, on both sw1 and sw2:

```
interface range Ethernet0/0 - 1
 channel-group 1 mode passive
```

Fix, on sw1 (one active side is enough, but put both back to active to match the baseline):

```
interface range Ethernet0/0 - 1
 channel-group 1 mode active
```

## 2. Mode on facing LACP

Break, on sw1:

```
interface range Ethernet0/0 - 1
 no channel-group
 channel-group 1 mode on
```

Fix, on sw1:

```
interface range Ethernet0/0 - 1
 no channel-group
 channel-group 1 mode active
```

## 3. LACP facing PAgP

Break, on sw2:

```
interface range Ethernet0/0 - 1
 no channel-group
 channel-group 1 mode desirable
```

Fix, on sw2:

```
interface range Ethernet0/0 - 1
 no channel-group
 channel-group 1 mode active
```

## 4. One member with different allowed VLANs

Break, on sw2:

```
interface Ethernet0/1
 switchport trunk allowed vlan 10
```

Fix, on sw2:

```
interface Ethernet0/1
 switchport trunk allowed vlan 10,20
```

## 5. One member in the wrong channel group

This stands in for a cable patched into the wrong port, or a port added to the wrong group. Break, on sw2 (IOS creates Port-channel2 for you):

```
interface Ethernet0/1
 no channel-group
 channel-group 2 mode active
```

Fix, on sw2:

```
interface Ethernet0/1
 no channel-group
 channel-group 1 mode active
exit
no interface Port-channel2
```
