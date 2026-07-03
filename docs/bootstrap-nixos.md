# Bootstrap NixOS

Installing NixOS from scratch on a new machine.

## Desktop vs Server

This guide covers both:
- **Desktop** (`hosts/nixos/`) - Full GUI with KDE, audio, etc.
- **Server/CI** (`hosts/nixos-ci/`) - Headless with SSH access

## Step 1: Boot Installer

Download the NixOS ISO from [nixos.org](https://nixos.org/download) and boot from it.

## Step 2: Network

```bash
# For WiFi
nmcli device wifi connect "SSID" password "password"

# Verify
ping -c 3 nixos.org
```

## Step 3: Partition Disks

Example for UEFI system with a single disk:

```bash
# Identify your disk (e.g., /dev/sda, /dev/nvme0n1)
lsblk

# Partition (adjust device name)
parted /dev/sda -- mmylabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MiB 100%

# Format
mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

## Step 4: Clone Configuration

Use HTTPS for the initial clone (SSH credentials aren't set up yet):

```bash
nix-shell -p git

git clone https://github.com/<org>/nix-config.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

> After installation, you'll set up SSH keys and can switch the remote to SSH:
> ```bash
> git remote set-url origin git@github.com:<org>/nix-config.git
> ```

## Step 5: Generate Hardware Config

```bash
nixos-generate-config --root /mnt --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

For a server/CI machine, use `hosts/nixos-ci/` instead.

## Step 6: Configure

Edit `flake.nix`:

```nix
userConfig = {
  username = "yourname";
  fullName = "Your Name";
  email = "you@example.com";
};
```

Edit `hosts/nixos/default.nix` (or `hosts/nixos-ci/default.nix`):
- Set `networking.hostName`
- Adjust user groups if needed

For server/CI, add your SSH public keys:

```nix
users.users.${username} = {
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA... your-key"
  ];
};
```

## Step 7: Install

```bash
# For desktop
nixos-install --flake .#nixos-workstation

# For server/CI
nixos-install --flake .#nixos-ci
```

Set the root password when prompted.

## Step 8: Reboot and Finish

```bash
reboot
```

After reboot:

```bash
# Set your user password
passwd yourname
```

## Step 9: Git Credentials

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "you@example.com"

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key to add to GitHub/GitLab
cat ~/.ssh/id_ed25519.pub
```

## Next Steps

See [Daily Workflow](workflow.md) for making changes and updates.
