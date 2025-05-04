#!/bin/bash
# scripts/setup-vpn-routing.sh
set -euo pipefail
export LC_ALL=C

INTERFACE="$1"
[ -z "$INTERFACE" ] && { echo "Error: Interface name not provided." >&2; exit 1; }

# Read config-params.yml file
CONFIG_PARAMS=$(cat config-params.yml)

# Extract Alias for the given interface
ALIAS=$(echo "$CONFIG_PARAMS" | yq e ".vpn_configs.$INTERFACE.Alias" -)
[ -z "$ALIAS" ] && { echo "Error: Alias for interface '$INTERFACE' not found in config-params.yml." >&2; exit 1; }

TABLE_NAME="${ALIAS}_tbl"
TABLE_ID=$(grep -w "$TABLE_NAME" /etc/iproute2/rt_tables | awk '{print $1}')
[ -z "$TABLE_ID" ] && { echo "Error: Table '$TABLE_NAME' not found." >&2; exit 1; }

sleep 1
WG_IP=$(ip -4 addr show dev "$ALIAS" | awk '/inet / {print $2}' | cut -d '/' -f 1)
echo "INFO ($ALIAS): Setting up table $TABLE_NAME (ID: $TABLE_ID)"

ip route add default dev "$ALIAS" table "$TABLE_ID"

if [ -n "$WG_IP" ]; then
    echo "INFO ($ALIAS): Adding rule for source IP $WG_IP"
    ip rule add from "$WG_IP" lookup "$TABLE_ID" priority 1000
else
    echo "WARN ($ALIAS): No IPv4 address found."
fi

FW_MARK=$TABLE_ID
echo "INFO ($ALIAS): Adding rule for fwmark $FW_MARK"
ip rule add fwmark "$FW_MARK" lookup "$TABLE_ID" priority 1100

echo "INFO ($ALIAS): Adding iptables rules"
iptables -A OUTPUT -o "$ALIAS" -j ACCEPT
iptables -A INPUT -i "$ALIAS" -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "INFO ($ALIAS): Setup complete."
exit 0