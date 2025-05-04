#!/bin/bash
# scripts/install-packages.sh
set -euo pipefail
export LC_ALL=C

echo "Updating package list..."
sudo apt-get update

echo "Installing WireGuard and iptables-persistent..."
sudo apt-get install -y wireguard iptables-persistent

# Install yq if not already installed
if ! command -v yq &> /dev/null; then
    echo "yq could not be found, installing yq..."
    sudo snap install yq
fi

# Install sed if not already installed
if ! command -v sed &> /dev/null; then
    echo "sed could not be found, installing sed..."
    sudo apt-get install -y sed
fi

echo "All required packages are installed."
exit 0