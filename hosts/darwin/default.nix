{ username, ... }:

{
  imports = [
    ../../modules/darwin/base.nix
    ../../modules/darwin/brew.nix
    ../../modules/darwin/system.nix
    ../../modules/darwin/home-manager.nix
  ];
  nixpkgs.config.allowUnfree = true;

  services.skhd.enable = true;

  system = {
    stateVersion = 6;
    primaryUser = username;
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
