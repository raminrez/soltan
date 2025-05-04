#!/bin/bash
# scripts/setup-base-firewall.sh
set -euo pipefail
export LC_ALL=C

# Ensure iptables-persistent is installed
if ! command -v iptables-save &> /dev/null; then
    echo "Error: iptables-persistent is not installed. Please install it first."
    exit 1
fi

# Flush existing rules and set chain policy settings
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH access
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow WireGuard traffic
for conf in /etc/wireguard/*.conf; do
    [ -f "$conf" ] || continue
    interface=$(basename "$conf" .conf)
    alias=$(yq e ".vpn_configs.$interface.Alias" config-params.yml)
    iptables -A INPUT -p udp --dport 51820 -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -i "$alias" -j ACCEPT
    iptables -A FORWARD -o "$alias" -j ACCEPT
done

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

echo "Base firewall setup complete."
exit 0