#!/bin/bash
# Set firewall configuration with iptables rules for differents servers use
# Pablo - github.com/juanpablodonoso
# Add - @reboot /thiscriptpath/iptables_set.sh - to crontab file to run at boot


# (1) For delete all actual rules (clean configuration)
 iptables -F 		# delete all rules in chains
 iptables -X			# delete a user-defined chain
 iptables -Z			# zero counters in chains
 iptables -t nat -F 	# delete all rules in NAT table 

# default conf: all accepted 
 iptables -p INPUT  ACCEPT
 iptables -p OUTPUT ACCEPT
 iptables -p FORWARD ACCEPT

# (2) For disable all traffic
 iptables -P INPUT DROP 	# drop  input trafic
 iptables -P OUTPUT DROP 	# drop output trafic
 iptables -P FORWARD DROP
 iptables –L –n -v 		# list in verbose and numeric mode the rules

# (3) enable localhost access (lo interface)
iptables -A INPUT -i lo -j ACCEPT	
iptables -A OUTPUT -o lo -j ACCEPT 

# open http  port
iptables -A INPUT --dport 80 -j ACCEPT
iptables -A OUTPUT --sport 80 -j ACCEPT
# open https port
iptables -A INPUT --dport 443 -j ACCEPT
iptables -A OUTPUT --sport 443 -j ACCEPT

# enable ssh access
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT


# (4) enable output with new, established and related 
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# enable concrete servers traffic
iptables -A INPUT -s 192.168.56.103 # load balancer server

# (5) for machines uses as firewall only and after enable ip-forwading: 
# To enable fordwading the traffic from firewall machine to destination server:
# Example: 
# 192.168.56.103 is the destination server, using enp0s8 in/out network interface and http only traffic
 iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.56.103
 iptables -A FORWARD --in-interface enp0s8 -j ACCEPT
 iptables -t nat -A POSTROUTING --out-interface enp0s8 -j MASQUERADE



