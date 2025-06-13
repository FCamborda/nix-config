# In ~/nixos-config/modules/shared/nix.nix
{ pkgs, ... }:

{
  nix = {
    package = pkgs.nix;
    settings = {
      # You might need to adjust the user variable here if needed
      trusted-users = [
        "@admin"
        "franco"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
