# VPN Setup Script

This repository contains scripts and configurations to set up a VPN on an Ubuntu system using WireGuard.

## Prerequisites

- An Ubuntu system with SSH access.
- Sufficient permissions to install packages and modify system configurations.

## Steps to Set Up VPN

1. **Clone the repository to your Ubuntu system:**

   ```bash
   git clone https://github.com/your-repo/vpn-repos.git
   cd vpn-repos/soltan
   ```

2. **Run the setup script:**

   ```bash
   ./scripts/setup-ubuntu.sh
   ```

   This script will:

   - Install the necessary packages (`wireguard` and `iptables-persistent`).
   - Ensure all scripts are executable.
   - Copy the WireGuard configuration files to `/etc/wireguard/`.
   - Set up a base firewall.
   - Set up VPN routing.
   - Enable and start the `vpn-sync.timer` to synchronize configuration files hourly.

## Notes

- Ensure you have `git` installed on your Ubuntu system. If not, you can install it using:

  ```bash
  sudo apt-get update
  sudo apt-get install -y git
  ```

- The `setup-ubuntu.sh` script requires `sudo` privileges to install packages and modify system configurations. You will be prompted for your password during the execution of the script.

## Troubleshooting

- If you encounter any issues, please check the output of the `setup-ubuntu.sh` script for error messages and follow the instructions provided.
