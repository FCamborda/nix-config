# Interactive Modules

Developer workstation modules for interactive use. Provides shell enhancements, editors, and local development tools.

**Not included on CI runners or servers** - those use only `modules/core/`.

## Files

- `home-manager.nix` - Shell configuration, editor setup
- `packages.nix` - Developer tools
- `config/` - Configuration files (shell theme, etc.)

## Usage

These modules are automatically imported by darwin and NixOS desktop configurations.

To add a developer tool that shouldn't be on CI/servers, add it here.
