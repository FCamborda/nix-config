# Daily Workflow

Working with nix-darwin and NixOS after initial setup.

## Applying Changes

After editing any configuration file:

```bash
# macOS
darwin-rebuild switch --flake .#infrastructure-macbook

# NixOS
sudo nixos-rebuild switch --flake .#nixos-workstation
```

Or use the alias (available after first rebuild):

```bash
nix-switch
```

## Common Tasks

### Add a Package

1. Find the package name: [search.nixos.org](https://search.nixos.org/packages)

2. Add it to the appropriate module:
   - `modules/core/packages.nix` - Available everywhere (including CI)
   - `modules/interactive/packages.nix` - Developer workstations only
   - `modules/darwin/brew.nix` - macOS GUI apps (Homebrew)

3. Rebuild

### Change a Program's Configuration

Programs are configured in:
- `modules/core/home-manager.nix` - git, neovim
- `modules/interactive/home-manager.nix` - shell, editor, fzf, etc.

### Change System Settings

- macOS: `modules/darwin/system.nix`
- NixOS desktop: `modules/nixos/desktop.nix`
- NixOS server: `modules/nixos/server.nix`

## Updating

### Update All Inputs

```bash
nix flake update
```

Then rebuild to apply.

### Update a Single Input

```bash
nix flake lock --update-input nixpkgs
nix flake lock --update-input home-manager
```

## Testing Changes

### Validate Flake

Check syntax and evaluate all configurations without building:

```bash
nix flake check
```

This validates:
- Flake structure is correct
- All configurations can be evaluated
- No obvious errors in module imports

### Build Without Applying

Build the configuration but don't activate it:

```bash
# macOS
darwin-rebuild build --flake .#infrastructure-macbook

# NixOS
nixos-rebuild build --flake .#nixos-workstation
```

The result is stored in `./result`. This catches build errors before affecting your system.

### Test in a VM (NixOS only)

Build and run your NixOS config in a QEMU virtual machine:

```bash
nixos-rebuild build-vm --flake .#nixos-workstation
./result/bin/run-*-vm
```

This boots a VM with your configuration. Useful for testing desktop changes, services, etc. without touching your real system.

> VM testing requires a graphical environment or VNC for desktop configs.

### Interactive Debugging

Open a Nix REPL with your flake loaded:

```bash
nix repl
:lf .
# Now you can inspect your config:
# darwinConfigurations.infrastructure-macbook.config.environment.systemPackages
```

### Dry Run

See what would change without doing it:

```bash
# macOS
darwin-rebuild build --flake .#infrastructure-macbook && nix store diff-closures /run/current-system ./result

# NixOS  
nixos-rebuild dry-activate --flake .#nixos-workstation
```

## Rollback

### macOS

List generations and switch to a previous one:

```bash
darwin-rebuild --list-generations
darwin-rebuild switch --rollback
```

### NixOS

During boot, select a previous generation from the bootloader menu.

Or from a running system:

```bash
nixos-rebuild --list-generations
sudo nixos-rebuild switch --rollback
```

## Garbage Collection

Remove old generations and free disk space:

```bash
# Remove generations older than 30 days
nix-collect-garbage --delete-older-than 30d

# Remove all old generations (keep only current)
nix-collect-garbage -d

# Also remove boot entries (NixOS)
sudo nixos-rebuild boot
```

## Troubleshooting

### "flake is dirty" warning

This just means you have uncommitted changes. It's informational, not an error.

### Build fails after update

```bash
# Rollback flake.lock
git checkout flake.lock
nix flake update
```

### "collision" errors

Two packages provide the same file. Remove one or use `lib.mkForce` to override.

### macOS: "cannot link" errors

Nix-darwin can't overwrite existing files. Back them up and retry:

```bash
sudo mv /etc/zshrc /etc/zshrc.backup
darwin-rebuild switch --flake .#infrastructure-macbook
```
