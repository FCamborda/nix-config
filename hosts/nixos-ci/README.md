# NixOS CI / Server Host

Headless configuration for CI runners and servers. No desktop environment.

## Setup

1. Generate hardware config on the target machine:
   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

2. Add SSH public keys in `default.nix`:
   ```nix
   users.users.${username} = {
     openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAA... your-key"
     ];
   };
   ```

3. Apply:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos-ci
   ```

## Adding CI Runner Services

To add GitHub Actions, GitLab Runner, or similar, create a module in `modules/nixos/` and import it here.
