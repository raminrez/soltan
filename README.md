# VPN Setup Guide

This repository contains scripts and configuration files to set up a WireGuard VPN on an Ubuntu system. Follow the steps below to install and configure the VPN.

## Prerequisites

- Ubuntu system
- `yq` installed (for YAML parsing)
- `sed` installed (for text replacement)

## Directory Structure

```
.
├── README.md
├── scripts/
│   ├── generate-configs.sh
│   ├── install-packages.sh
│   ├── setup-base-firewall.sh
│   ├── setup-ubuntu.sh
│   ├── setup-vpn-routing.sh
│   └── teardown-vpn-routing.sh
├── systemd/
│   ├── vpn-sync.service
│   └── vpn-sync.timer
└── template/
    └── wiregaurd.congs
```

## Setup Steps

1. **Install Required Packages**

   Run the `install-packages.sh` script to install the necessary packages.

   ```bash
   ./scripts/install-packages.sh
   ```

2. **Ensure Scripts are Executable**

   Make sure all scripts are executable.

   ```bash
   chmod +x scripts/*.sh
   ```

3. **Generate Configuration Files**

   Run the `generate-configs.sh` script to generate the WireGuard configuration files based on the parameters in `config-params.yml`.

   ```bash
   ./scripts/generate-configs.sh
   ```

4. **Copy Configuration Files**

   Copy the generated configuration files to the WireGuard directory.

   ```bash
   sudo cp configs/*.conf /etc/wireguard/
   sudo chmod 600 /etc/wireguard/*.conf
   ```

5. **Set Up Base Firewall**

   Run the `setup-base-firewall.sh` script to set up the base firewall rules.

   ```bash
   ./scripts/setup-base-firewall.sh
   ```

6. **Set Up VPN Routing**

   Run the `setup-vpn-routing.sh` script to set up the VPN routing.

   ```bash
   ./scripts/setup-vpn-routing.sh
   ```

7. **Enable and Start VPN Sync Timer**

   Enable and start the `vpn-sync.timer` to periodically sync the VPN configuration.

   ```bash
   sudo cp systemd/vpn-sync.service /etc/systemd/system/
   sudo cp systemd/vpn-sync.timer /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable vpn-sync.timer
   sudo systemctl start vpn-sync.timer
   ```

## Configuration Files

- **`config-params.yml`**: Contains the parameters for each VPN configuration.
- **`template/wiregaurd.congs`**: Template for generating WireGuard configuration files.

## Environment Variables

- **`.env`**: Contains environment variables such as `PRIVATE_KEY` and `PRE_SHARED_KEY`.

## Scripts

- **`install-packages.sh`**: Installs required packages.
- **`setup-base-firewall.sh`**: Sets up the base firewall rules.
- **`setup-vpn-routing.sh`**: Sets up the VPN routing.
- **`teardown-vpn-routing.sh`**: Tears down the VPN routing.
- **`generate-configs.sh`**: Generates WireGuard configuration files based on `config-params.yml`.
- **`setup-ubuntu.sh`**: Main script to set up the VPN on Ubuntu.

## Systemd Services

- **`vpn-sync.service`**: Systemd service to sync the VPN configuration.
- **`vpn-sync.timer`**: Systemd timer to periodically run the `vpn-sync.service`.

## Usage

To set up the VPN, run the `setup-ubuntu.sh` script.

```bash
./scripts/setup-ubuntu.sh
```

This script will execute all the necessary steps to set up the VPN on your Ubuntu system.

## Troubleshooting

- Ensure all scripts are executable.
- Verify that the `config-params.yml` file contains the correct parameters for each VPN configuration.
- Check the generated configuration files in the `configs/` directory.
- Ensure that the `wiregaurd.congs` template file has the correct placeholders.
