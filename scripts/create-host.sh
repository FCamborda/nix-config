#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat << 'EOF'
Create a new NixOS host configuration.

This script generates the directory structure and config files for a new
NixOS host. It does NOT install or provision anything - it only creates
the Nix configuration files that you then deploy.

USAGE:
  ./scripts/create-host.sh <hostname> <type>
  ./scripts/create-host.sh --help

TYPES:
  desktop   Developer workstation with KDE, audio, full dev tools
  server    Headless CI runner or server with SSH, Podman

EXAMPLES:
  ./scripts/create-host.sh my-workstation desktop
  ./scripts/create-host.sh ci-runner-01 server

WHAT IT CREATES:
  hosts/<hostname>/
  ├── default.nix              # Host configuration (imports appropriate modules)
  └── hardware-configuration.nix   # Placeholder (generate on target machine)

NEXT STEPS (printed after running):
  1. Add the host to flake.nix
  2. Generate hardware-configuration.nix on target machine
  3. Add SSH keys (for servers)
  4. Deploy

For macOS hosts, edit flake.nix directly - see docs/adding-hosts.md
EOF
}

if [[ $# -lt 1 ]] || [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

if [[ $# -lt 2 ]]; then
  echo "Error: Missing type argument (desktop or server)"
  echo ""
  echo "Usage: $0 <hostname> <type>"
  echo "Run '$0 --help' for more information."
  exit 1
fi

HOSTNAME="$1"
TYPE="$2"
HOST_DIR="hosts/${HOSTNAME}"

if [[ "$TYPE" != "desktop" ]] && [[ "$TYPE" != "server" ]]; then
  echo "Error: Invalid type '$TYPE'. Must be 'desktop' or 'server'."
  exit 1
fi

if [[ -d "$HOST_DIR" ]]; then
  echo "Error: $HOST_DIR already exists"
  exit 1
fi

echo "Creating $TYPE host: $HOSTNAME"

mkdir -p "$HOST_DIR"

# Create default.nix based on type
if [[ "$TYPE" == "desktop" ]]; then
  cat > "$HOST_DIR/default.nix" << 'EOF'
{
  config,
  pkgs,
  username,
  fullName,
  email,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/home-manager.nix
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    initialPassword = "changeme";
  };

  system.stateVersion = "25.05";
}
EOF
else
  cat > "$HOST_DIR/default.nix" << 'EOF'
{
  config,
  pkgs,
  username,
  fullName,
  email,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/home-manager-server.nix
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      # Add SSH public keys here
      # "ssh-ed25519 AAAA... comment"
    ];
  };

  system.stateVersion = "25.05";
}
EOF
fi

# Create placeholder hardware-configuration.nix
cat > "$HOST_DIR/hardware-configuration.nix" << 'EOF'
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # PLACEHOLDER - Generate on target machine with:
  # nixos-generate-config --show-hardware-config
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
EOF

echo ""
echo "Created $HOST_DIR/"
echo ""
echo "Next steps:"
echo "1. Add to flake.nix:"
echo ""
echo "   nixosConfigurations.\"$HOSTNAME\" = mkNixOS {"
echo "     hostname = \"$HOSTNAME\";"
echo "     hostPath = ./hosts/$HOSTNAME;"
echo "   };"
echo ""
echo "2. Generate hardware config on target machine:"
echo "   nixos-generate-config --show-hardware-config > hosts/$HOSTNAME/hardware-configuration.nix"
echo ""
echo "3. Add SSH keys (for servers) in hosts/$HOSTNAME/default.nix"
echo ""
echo "4. Deploy with: sudo nixos-rebuild switch --flake .#$HOSTNAME"
