# Adding Hosts

How to add new machines to this configuration.

## NixOS (Desktop or Server)

### Step 1: Create the Host

```bash
# Desktop (KDE, audio, full dev tools)
./scripts/create-host.sh my-workstation desktop

# Server/CI (headless, SSH, Podman)
./scripts/create-host.sh ci-runner-01 server
```

### Step 2: Add to flake.nix

```nix
nixosConfigurations."my-workstation" = mkNixOS {
  hostname = "my-workstation";
  hostPath = ./hosts/my-workstation;
};
```

### Step 3: Customize

- **Hardware config**: Generate on target machine with `nixos-generate-config --show-hardware-config`
- **SSH keys** (servers): Edit `hosts/<name>/default.nix` to add authorized keys
- **User override** (optional): See [User Configuration](#user-configuration) below

### Step 4: Deploy

```bash
sudo nixos-rebuild switch --flake .#my-workstation
```

For remote provisioning, see [Server Provisioning](server-provisioning.md).

## macOS

```nix
# Add to flake.nix
darwinConfigurations."your-macbook" = mkDarwin {
  hostname = "your-macbook";
};
```

Then bootstrap on the new machine following [Bootstrap macOS](bootstrap-macos.md).

## User Configuration

The `userConfig` in `flake.nix` is the default for all hosts. For teams, override per-host:

### Servers: Use a Deploy User

Servers don't need personal configs. Override with a shared service account:

```nix
nixosConfigurations."ci-runner-01" = mkNixOS {
  hostname = "ci-runner-01";
  hostPath = ./hosts/ci-runner-01;
  extraModules = [{
    _module.args = {
      username = "deploy";
      fullName = "Deploy User";
      email = "infra@company.com";
    };
  }];
};
```

### Team Workstations

Define users and assign to hosts:

```nix
users = {
  alice = { username = "alice"; fullName = "Alice"; email = "alice@example.com"; };
  bob = { username = "bob"; fullName = "Bob"; email = "bob@example.com"; };
};

darwinConfigurations."alice-macbook" = mkDarwin {
  hostname = "alice-macbook";
  extraModules = [{ _module.args = users.alice; }];
};
```

## Secrets Management

For sensitive data (API keys, tokens, passwords), don't put them in the repo. Use:

- **[sops-nix](https://github.com/Mic92/sops-nix)** - Encrypts secrets in-repo, decrypts at build time
- **[agenix](https://github.com/ryantm/agenix)** - Similar, uses age encryption

These integrate with NixOS and allow secrets to be version-controlled safely.

## Host-Specific Overrides

To add packages or settings for a specific host only, edit that host's `default.nix`:

```nix
# In hosts/your-hostname/default.nix
{
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    some-special-tool
  ];

  # Host-specific services
  services.postgresql.enable = true;
}
```
