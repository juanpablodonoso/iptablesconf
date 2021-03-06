#!/bin/bash
# Set firewall configuration with iptables rules for differents servers use and secure the a web farm.
# Pablo - github.com/juanpablodonoso
# Add - @reboot /thiscriptpath/iptables_set.sh - to crontab file to run at boot
# Run sudo iptables_set.sh && sudo iptbles -L -n -v 


# (1) For delete all actual rules (clean configuration)
 iptables -F 		# delete all rules in chains
 iptables -X			# delete a user-defined chain
 iptables -Z			# zero counters in chains
 iptables -t nat -F 	# delete all rules in NAT table 

# default conf: all accepted 
 iptables -P INPUT  ACCEPT
 iptables -P OUTPUT ACCEPT
 iptables -P FORWARD ACCEPT

# (2) For disable all traffic
 iptables -P INPUT DROP 	# drop  input trafic
 iptables -P OUTPUT DROP 	# drop output trafic
 iptables -P FORWARD DROP
# iptables –L –n -v 		# list in verbose and numeric mode the rules

# (3) enable concrete points acces  

# enable localhost access (lo interface)
iptables -A INPUT -i lo -j ACCEPT	
iptables -A OUTPUT -o lo -j ACCEPT 

# open http  port (port 80)
iptables -A INPUT -p tcp  --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
# open https (port 443)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
# enable ssh access (port 22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# enable dns (port 53)
# iptables -A INPUT -m state --state NEW -p udp --dport 53 -j ACCEPT
# iptables -A INPUT -m state --state NEW -p tcp --dport 53 -j ACCEPT

# enables mysql (port 3306)
iptables -A INPUT -i eth0 -p tcp -m tcp --dport 3306 -j ACCEP

# (4) enable output with new, established and related 
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# enable concrete input/ouput servers traffic 
iptables -A INPUT  -s 192.168.56.103 -j ACCEPT # load balancer server
iptables -A OUTPUT -s 192.168.56.103 -j ACCEPT # load balancer server

# (5) for machines uses as firewall only and after enable ip-forwading: 
# To enable fordwading the traffic from firewall machine (first line machine in the web farm) to destination server:
# Example: 
# 192.168.56.103 (VIP) is the destination server, using enp0s8 in/out network interface and http only traffic
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.56.103
iptables -A FORWARD --in-interface enp0s8 -j ACCEPT
iptables -t nat -A POSTROUTING --out-interface enp0s8 -j MASQUERADE



