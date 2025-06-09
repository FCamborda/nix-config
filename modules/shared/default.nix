# In ~/nixos-config/modules/shared/default.nix
{
  # This file's only job is to list all the other modules in this directory.

  imports = [
    # Import the module for nixpkgs settings and overlays
    ./nixpkgs-config.nix

    # Import the module for Nix settings (garbage collection, etc.)
    ./nix.nix

    # If you have other shared modules for git, zsh, etc.
    # you would list them here too. For example:
    # ./git.nix
    # ./zsh.nix
  ];
}
