# NixOS Desktop Host

Developer workstation configuration with full GUI environment.

## Setup

1. Generate hardware config on the target machine:
   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

2. Edit `default.nix` to set hostname and user groups as needed.

3. Apply:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos-workstation
   ```

## Files

- `default.nix` - Host entry point, user configuration
- `hardware-configuration.nix` - Hardware-specific settings (generate per-machine)
