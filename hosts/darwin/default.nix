{ pkgs, username, ... }:

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/darwin/system.nix
    ../../modules/shared
  ];

  # Enable the skhd service at the system level
  services.skhd.enable = true;

  environment.systemPackages = import ../../modules/darwin/packages.nix { inherit pkgs; };
  # This defines your user for the entire system, making it
  # visible to Home Manager and other modules.
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
  system = {
    checks.verifyNixPath = false;
    stateVersion = 4;
    primaryUser = username;
  };
}
