#!/bin/bash
# scripts/setup-ubuntu.sh
set -euo pipefail
export LC_ALL=C

# Step 1: Install required packages
echo "Running package installation script..."
./scripts/install-packages.sh

# Step 2: Ensure scripts are executable
echo "Ensuring scripts are executable..."
chmod +x scripts/install-packages.sh
chmod +x scripts/setup-base-firewall.sh
chmod +x scripts/setup-vpn-routing.sh
chmod +x scripts/teardown-vpn-routing.sh
chmod +x scripts/setup-ubuntu.sh
chmod +x scripts/generate-configs.sh

# Step 3: Generate configuration files
echo "Generating configuration files..."
./scripts/generate-configs.sh

# Step 4: Copy configuration files
echo "Copying configuration files..."
sudo cp configs/*.conf /etc/wireguard/
sudo chmod 600 /etc/wireguard/*.conf

# Step 5: Set up base firewall
echo "Setting up base firewall..."
./scripts/setup-base-firewall.sh

# Step 6: Set up VPN routing
echo "Setting up VPN routing..."
./scripts/setup-vpn-routing.sh

# Step 7: Enable and start vpn-sync.timer
echo "Enabling and starting vpn-sync.timer..."
sudo cp systemd/vpn-sync.service /etc/systemd/system/
sudo cp systemd/vpn-sync.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vpn-sync.timer
sudo systemctl start vpn-sync.timer

echo "Setup complete."
exit 0