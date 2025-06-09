{ config, pkgs, ... }:

let user = "franco"; in

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
  users.users.franco = {
    name = "franco";
    home = "/Users/franco";
  };
  system = {
    checks.verifyNixPath = false;
    stateVersion = 4;
    primaryUser = "franco";
  };
}
