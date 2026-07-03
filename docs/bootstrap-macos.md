# Bootstrap macOS

Setting up a fresh Mac from scratch.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Admin access
- Case-sensitive filesystem recommended (APFS Case-sensitive)

> **Filesystem note:** macOS defaults to case-insensitive. For development, use a case-sensitive volume to avoid issues with git repos that have files differing only by case. You can create a separate APFS volume for development work if your main volume is case-insensitive.

## Step 1: Install Nix

nix-darwin recommends the [Lix installer](https://lix.systems/install/) because it includes an automated uninstaller. The installer you choose doesn't affect which Nix implementation you'll use - nix-darwin manages that.

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Alternatively, use the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, open a new terminal or run:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

## Step 2: Clone Configuration

```bash
git clone https://github.com/<org>/nix-config.git
cd nix-config
```

## Step 3: Configure Identity

Edit `flake.nix` and update the `userConfig` section:

```nix
userConfig = {
  username = "yourname";        # Your macOS username
  fullName = "Your Name";       # Used in git config
  email = "you@example.com";    # Used in git config
};
```

## Step 4: Bootstrap nix-darwin

Run the initial setup (this installs nix-darwin):

```bash
nix run nix-darwin -- switch --flake .#infrastructure-macbook
```

This will:
- Install nix-darwin
- Apply your configuration
- Set up your shell, packages, and system settings

## Step 5: Git Credentials

After the first rebuild, configure git authentication:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "you@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

Add the key to your GitHub/GitLab account, then test:

```bash
ssh -T git@github.com
```

## Step 6: Verify

Open a new terminal and verify everything works:

```bash
# Check nix-darwin is working
darwin-rebuild --version

# Your configured tools should be available
git --version
nvim --version
```

## Next Steps

See [Daily Workflow](workflow.md) for making changes and updates.
