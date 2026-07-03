{
  username,
  fullName,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/home-manager.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixos-workstation";

  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    initialPassword = "changeme";
  };

  system.stateVersion = "25.05";
}
