#!/bin/bash
# scripts/install-packages.sh
set -euo pipefail
export LC_ALL=C

echo "Updating package list..."
sudo apt-get update

echo "Installing WireGuard and iptables-persistent..."
sudo apt-get install -y wireguard iptables-persistent

echo "Package installation complete."
exit 0