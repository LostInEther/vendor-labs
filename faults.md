# Breaking the lab

Each fault starts from the working baseline. Apply the "break" commands, follow the blog post to diagnose it, then apply the "fix" commands before moving on.

To watch a fault, run the debug flow on fgt02, filtered on the address you're testing (203.0.113.10 for faults 1 to 3, 1.1.1.1 for faults 4 and 5):

```
diagnose debug reset
diagnose debug flow filter addr 203.0.113.10
diagnose debug flow show function-name enable
diagnose debug flow trace start 10
diagnose debug enable
```

Reproduce the problem from client01, then run `diagnose debug disable`.

After any policy change, wait about 10 seconds before testing. In the lab, the FortiGate was still using the old policy straight after `end`.

## 1. No policy matches

Break, on fgt02:

```
config firewall policy
    edit 1
        set status disable
    next
end
```

Test, on client01:

```
ping -c 3 203.0.113.10
```

Fix, on fgt02:

```
config firewall policy
    edit 1
        set status enable
    next
end
```

## 2. A deny above the allow

Break, on fgt02. This uses policy ID 3, because ID 2 is the internet policy in the baseline config. In the blog post the block was policy 2, so where the post shows `policy 2`, you'll see `policy 3`.

```
config firewall policy
    edit 3
        set name "Block-Web-Temp"
        set srcintf "port2"
        set dstintf "port1"
        set srcaddr "all"
        set dstaddr "all"
        set action deny
        set schedule "always"
        set service "HTTP"
    next
    move 3 before 1
end
```

Test, on client01 (the ping works, the curl doesn't):

```
ping -c 3 203.0.113.10
curl --max-time 5 http://203.0.113.10
```

Check which policy the curl matches, without sending traffic:

```
diagnose firewall iprope lookup 198.51.100.10 40000 203.0.113.10 80 6 port2
```

Fix, on fgt02:

```
config firewall policy
    delete 3
end
```

## 3. Reverse path check failure

Nothing to break on fgt02. Simulate a user on a new subnet, 10.99.0.0/24, on client01:

```
ip addr add 10.99.0.10/32 dev eth1
ping -c 3 -I 10.99.0.10 203.0.113.10
curl --max-time 5 --interface 10.99.0.10 http://203.0.113.10
```

Fix, on fgt02:

```
config router static
    edit 1
        set dst 10.99.0.0 255.255.255.0
        set gateway 198.51.100.10
        set device "port2"
    next
end
```

To return to the baseline afterwards, delete the route (`config router static`, `delete 1`, `end`) and remove the address on client01 with `ip addr del 10.99.0.10/32 dev eth1`.

## 4. No route to the destination

Break, on fgt02:

```
config system interface
    edit port3
        set defaultgw disable
    next
end
```

Test, on client01 (the internet fails with "Destination Net Unreachable", srv01 still works):

```
ping -c 3 1.1.1.1
curl --max-time 5 http://203.0.113.10
```

Fix, on fgt02:

```
config system interface
    edit port3
        set defaultgw enable
    next
end
```

## 5. No NAT

Break, on fgt02, then clear the existing sessions so old ones can't skew the test:

```
config firewall policy
    edit 2
        set nat disable
    next
end
diagnose sys session filter clear
diagnose sys session filter dst 1.1.1.1
diagnose sys session clear
diagnose sys session filter clear
```

Test, on client01:

```
ping -c 3 1.1.1.1
```

To see what leaves the firewall, run this on fgt02 while you ping. With no replies it never reaches its count of 6, so press Ctrl+C to stop it:

```
diagnose sniffer packet port3 'host 1.1.1.1' 4 6
```

Fix, on fgt02: `set nat enable` on policy 2, then clear the sessions again with the same four `diagnose sys session` commands.
