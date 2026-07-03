# Nix Configuration

Declarative system configuration for **macOS** and **NixOS** (desktops and servers).

## Documentation

| Document | Description |
|----------|-------------|
| [Bootstrap macOS](docs/bootstrap-macos.md) | Fresh Mac setup from scratch |
| [Bootstrap NixOS](docs/bootstrap-nixos.md) | Fresh NixOS installation (manual) |
| [Server Provisioning](docs/server-provisioning.md) | Automated deployment for servers/CI |
| [Daily Workflow](docs/workflow.md) | Making changes, updating, troubleshooting |
| [Adding Hosts](docs/adding-hosts.md) | Adding new machines to this config |
| [FAQ](FAQ.md) | Common questions |

## Quick Reference

Once bootstrapped, apply configuration changes with:

```bash
nix-switch
```

This alias is configured per-host and runs the appropriate rebuild command.

## Directory Structure

```
.
├── flake.nix           # Entry point - edit userConfig here
├── hosts/              # Machine-specific configurations
├── modules/
│   ├── core/           # Headless-safe (all systems including CI)
│   ├── interactive/    # Developer workstations only
│   ├── darwin/         # macOS-specific
│   └── nixos/          # NixOS-specific
└── docs/               # Documentation
```

To understand what's installed, read the modules directly. The code is the documentation.
