#!/bin/bash
# scripts/teardown-vpn-routing.sh
set -euo pipefail
export LC_ALL=C

INTERFACE="$1"
[ -z "$INTERFACE" ] && { echo "Error: Interface name not provided." >&2; exit 1; }

TABLE_NAME="${INTERFACE}_tbl"
TABLE_ID=$(grep -w "$TABLE_NAME" /etc/iproute2/rt_tables | awk '{print $1}')
[ -z "$TABLE_ID" ] && echo "WARN ($INTERFACE): Table '$TABLE_NAME' not found."

WG_IP=$(ip -4 addr show dev "$INTERFACE" 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1)
echo "INFO ($INTERFACE): Tearing down table $TABLE_NAME (ID: $TABLE_ID)"

if [ -n "$WG_IP" ]; then
    echo "INFO ($INTERFACE): Removing rule for source IP $WG_IP"
    ip rule del from "$WG_IP" lookup "$TABLE_ID" priority 1000 2>/dev/null || true
fi
if [ -n "$TABLE_ID" ]; then
    FW_MARK=$TABLE_ID
    echo "INFO ($INTERFACE): Removing rule for fwmark $FW_MARK"
    ip rule del fwmark "$FW_MARK" lookup "$TABLE_ID" priority 1100 2>/dev/null || true
fi

if [ -n "$TABLE_ID" ]; then
    echo "INFO ($INTERFACE): Flushing table $TABLE_ID"
    ip route flush table "$TABLE_ID"
fi

echo "INFO ($INTERFACE): Removing iptables rules"
iptables -D OUTPUT -o "$INTERFACE" -j ACCEPT 2>/dev/null || true
iptables -D INPUT -i "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

echo "INFO ($INTERFACE): Teardown complete."
exit 0