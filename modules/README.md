# Modules

Reusable Nix modules organized by scope and platform.

```
modules/
├── core/           # Headless-safe (all systems including CI)
├── interactive/    # Developer workstations only
├── darwin/         # macOS-specific
└── nixos/          # NixOS-specific
```

## Module Layers

- **`core/`** - Included everywhere. Add tools here that CI runners need.
- **`interactive/`** - Developer machines only. Add tools here that don't belong on servers.
- **`darwin/`** - macOS system configuration.
- **`nixos/`** - NixOS system configuration with desktop/server split.

Read each module's README and source files for details.
