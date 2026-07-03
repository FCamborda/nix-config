# Server Provisioning

Automated approaches for deploying NixOS to servers and CI runners.

> **Note:** These methods **replace the existing OS** with NixOS. The target machine will be wiped and reprovisioned. Only use on machines you intend to provision fresh.

## Options Overview

| Method | Use Case | Requirements |
|--------|----------|--------------|
| **NixOS Anywhere** | Any machine with SSH access (on-prem or cloud) | SSH + temporary Linux boot |
| **nixos-infect** | Quick conversion of existing Linux | Root access |
| **Custom ISO** | Bare metal, air-gapped environments | Physical access |
| **PXE Boot** | Data center / fleet provisioning | PXE infrastructure |

## On-Premises Scenarios

### Physical Servers (with IPMI/BMC)

1. Boot a minimal Linux via IPMI virtual media or USB
2. Ensure SSH is accessible
3. Run nixos-anywhere from your workstation

### VM Hypervisors (Proxmox, VMware, libvirt)

1. Create VM with any Linux template (Ubuntu, Debian, Alpine)
2. Note the VM's IP address
3. Run nixos-anywhere to convert to NixOS

### Existing Linux Servers

If you have existing on-prem Linux servers you want to convert:

1. Ensure SSH root access
2. Run nixos-anywhere - it will reboot into NixOS

### Air-Gapped / No Network Boot

For environments without network access during install:
1. Build a custom ISO with your config baked in
2. Boot from USB/DVD
3. The system installs itself

## NixOS Anywhere (Recommended for Remote Servers)

[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) can install NixOS on any Linux machine via SSH - even if it's currently running Ubuntu, Debian, etc.

### Prerequisites

- SSH access to the target machine
- Target has at least 1.5GB RAM (for kexec)
- Your local machine has Nix installed

### Step 1: Create the Host

Use the generator script (see [Adding Hosts](adding-hosts.md)):

```bash
./scripts/create-host.sh my-server server
```

Then add a `disk-config.nix` for disko (nixos-anywhere uses [disko](https://github.com/nix-community/disko) for declarative partitioning):

Update `hosts/my-server/default.nix` to import it:

```nix
imports = [
  ./disk-config.nix  # Add this
  ./hardware-configuration.nix
  # ...
];
```

Create `hosts/my-server/disk-config.nix`:

```nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";  # Adjust for your server
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
```

### Step 2: Add Disko Input to Flake

Update `flake.nix`:

```nix
inputs = {
  # ... existing inputs ...
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

And include disko in the modules:

```nix
mkNixOS = { system ? "x86_64-linux", hostname, hostPath, extraModules ? [ ] }:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = userConfig // { inherit hostname; };
    modules = [
      hostPath
      disko.nixosModules.disko  # Add this
      home-manager.nixosModules.home-manager
    ] ++ extraModules;
  };
```

### Step 3: Deploy

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#my-server \
  root@server-ip
```

This will:
1. Boot the target into a temporary NixOS installer (via kexec)
2. Partition the disk according to your disko config
3. Install your NixOS configuration
4. Reboot into the new system

## nixos-infect (Quick VPS Conversion)

[nixos-infect](https://github.com/elitak/nixos-infect) converts an existing Linux VPS to NixOS in-place.

```bash
# SSH into your VPS, then run:
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.05 bash -x
```

After reboot, clone your config and apply. See [Bootstrap NixOS](bootstrap-nixos.md) for the full steps (start from "Clone Configuration").

## Custom ISO (On-Prem / Air-Gapped)

Build a bootable ISO with your configuration baked in:

```bash
# Build ISO for a specific host
nix build .#nixosConfigurations.nixos-ci.config.system.build.isoImage

# Result is in ./result/iso/
ls result/iso/
```

To enable this, add to your host configuration:

```nix
# hosts/nixos-ci/default.nix
{
  # ... existing config ...
  
  # Enable ISO building
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
```

Write to USB and boot:

```bash
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress
```

## PXE Boot (Data Center Fleet)

For provisioning many on-prem machines, set up PXE boot with netboot.xyz or a custom TFTP server. NixOS can generate netboot images:

```bash
nix build .#nixosConfigurations.nixos-ci.config.system.build.netbootRamdisk
nix build .#nixosConfigurations.nixos-ci.config.system.build.kernel
nix build .#nixosConfigurations.nixos-ci.config.system.build.netbootIpxeScript
```

See the [NixOS Wiki on PXE](https://wiki.nixos.org/wiki/Netboot) for TFTP/DHCP setup.

## Updating Remote Servers

After initial provisioning, update servers by pushing config changes and rebuilding:

```bash
# Option 1: SSH and rebuild locally
ssh user@server "cd /etc/nixos && git pull && sudo nixos-rebuild switch --flake .#my-server"

# Option 2: Build locally, copy closure
nixos-rebuild switch --flake .#my-server --target-host user@server --build-host localhost
```

## Multiple Servers

For managing many servers, consider:

- **[deploy-rs](https://github.com/serokell/deploy-rs)** - Declarative deployment tool
- **[colmena](https://github.com/zhaofengli/colmena)** - NixOS deployment tool for fleets
- **CI/CD pipeline** - Auto-deploy on git push

Example with deploy-rs in `flake.nix`:

```nix
outputs = { self, nixpkgs, deploy-rs, ... }: {
  deploy.nodes.my-server = {
    hostname = "server-ip";
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.my-server;
    };
  };
};
```

Then deploy with:

```bash
nix run github:serokell/deploy-rs -- .#my-server
```
