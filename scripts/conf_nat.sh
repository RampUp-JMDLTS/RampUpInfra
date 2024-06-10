#!/bin/bash

sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables

# Turning on IP Forwarding
sudo touch /etc/sysctl.d/custom-ip-forwarding.conf
sudo chmod 666 /etc/sysctl.d/custom-ip-forwarding.conf
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/custom-ip-forwarding.conf
sudo sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

# Making a catchall rule for routing and masking the private IP
X=$(netstat -i | awk 'NR>2 {print $1}' | grep -E "^e")
sudo /sbin/iptables -t nat -A POSTROUTING -o $X -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save