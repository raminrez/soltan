#!/bin/bash
# scripts/generate-configs.sh
set -euo pipefail
export LC_ALL=C

# Read .env file
source .env

# Read config-params.yml file
CONFIG_PARAMS=$(cat config-params.yml)

# Extract VPN configurations
VPN_CONFIGS=$(echo "$CONFIG_PARAMS" | yq e '.vpn_configs | keys' -)

# Read template file
TEMPLATE=$(cat template/wiregaurd.congs)

# Create configs directory if it doesn't exist
mkdir -p configs

# Generate configuration files for each VPN configuration
for VPN_CONFIG in $VPN_CONFIGS; do
    echo "Generating configuration for $VPN_CONFIG..."
    CONFIG_FILE="configs/${VPN_CONFIG}.conf"
    
    # Extract specific VPN configuration parameters
    PUBLIC_KEY=$(echo "$CONFIG_PARAMS" | yq e ".vpn_configs.$VPN_CONFIG.PublicKey" -)
    ENDPOINT=$(echo "$CONFIG_PARAMS" | yq e ".vpn_configs.$VPN_CONFIG.Endpoint" -)
    SERVER_PUBLIC_KEY=${PUBLIC_KEY}
    SERVER_IP=$(echo "$ENDPOINT" | cut -d':' -f1)
    PORT=$(echo "$ENDPOINT" | cut -d':' -f2)
    PRE_SHARED_KEY=$(echo "$CONFIG_PARAMS" | yq e ".vpn_configs.$VPN_CONFIG.PresharedKey" -)
    
    # Replace placeholders in the template
    CONFIG_CONTENT=$(echo "$TEMPLATE" | sed "s|<PRIVATE_KEY>|$PRIVATE_KEY|g" | sed "s|<CLIENT_IP>|100.76.79.157|g" | sed "s|<SERVER_PUBLIC_KEY>|$SERVER_PUBLIC_KEY|g" | sed "s|<SERVER_IP>|$SERVER_IP|g" | sed "s|<PORT>|$PORT|g" | sed "s|<PRE_SHARED_KEY>|${PRE_SHARED_KEY:-$PRE_SHARED_KEY}|g")
    
    # Write the configuration file
    echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
done

echo "Configuration files generated successfully."
exit 0