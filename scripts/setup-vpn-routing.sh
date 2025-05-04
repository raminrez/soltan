#!/bin/bash
# scripts/setup-vpn-routing.sh
set -euo pipefail
export LC_ALL=C

INTERFACE="$1"
[ -z "$INTERFACE" ] && { echo "Error: Interface name not provided." >&2; exit 1; }

TABLE_NAME="${INTERFACE}_tbl"
TABLE_ID=$(grep -w "$TABLE_NAME" /etc/iproute2/rt_tables | awk '{print $1}')
[ -z "$TABLE_ID" ] && { echo "Error: Table '$TABLE_NAME' not found." >&2; exit 1; }

sleep 1
WG_IP=$(ip -4 addr show dev "$INTERFACE" | awk '/inet / {print $2}' | cut -d '/' -f 1)
echo "INFO ($INTERFACE): Setting up table $TABLE_NAME (ID: $TABLE_ID)"

ip route add default dev "$INTERFACE" table "$TABLE_ID"

if [ -n "$WG_IP" ]; then
    echo "INFO ($INTERFACE): Adding rule for source IP $WG_IP"
    ip rule add from "$WG_IP" lookup "$TABLE_ID" priority 1000
else
    echo "WARN ($INTERFACE): No IPv4 address found."
fi

FW_MARK=$TABLE_ID
echo "INFO ($INTERFACE): Adding rule for fwmark $FW_MARK"
ip rule add fwmark "$FW_MARK" lookup "$TABLE_ID" priority 1100

echo "INFO ($INTERFACE): Adding iptables rules"
iptables -A OUTPUT -o "$INTERFACE" -j ACCEPT
iptables -A INPUT -i "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "INFO ($INTERFACE): Setup complete."
exit 0