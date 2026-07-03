# Core Modules

Headless-safe modules included on all systems: developer workstations, CI runners, and servers.

These modules contain no GUI dependencies and work in non-interactive environments.

## Files

- `home-manager.nix` - User programs (git, neovim)
- `packages.nix` - CLI tools

## Usage

These modules are automatically imported by both desktop and server configurations.

To add a tool that should be available everywhere (including CI), add it here.
