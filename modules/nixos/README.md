# NixOS Modules

NixOS-specific system configuration.

## Files

| File | Purpose |
|------|---------|
| `base.nix` | Nix settings, locale, timezone - all NixOS systems |
| `server.nix` | Headless services (SSH, Podman, firewall) |
| `desktop.nix` | GUI environment (imports server.nix) |
| `home-manager.nix` | Full Home Manager (core + interactive) |
| `home-manager-server.nix` | Minimal Home Manager (core only) |

## Configuration Types

**Desktop** (developer workstation):
```nix
imports = [
  ../../modules/nixos/base.nix
  ../../modules/nixos/desktop.nix
  ../../modules/nixos/home-manager.nix
];
```

**Server / CI** (headless):
```nix
imports = [
  ../../modules/nixos/base.nix
  ../../modules/nixos/server.nix
  ../../modules/nixos/home-manager-server.nix
];
```

## Hardware Configuration

On actual hardware, generate the config with:

```bash
nixos-generate-config --show-hardware-config
```
