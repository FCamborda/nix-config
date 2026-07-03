{
  username,
  fullName,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/home-manager-server.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixos-ci";

  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here for CI access
      # "ssh-ed25519 AAAA... your-key-comment"
    ];
  };

  system.stateVersion = "25.05";
}
