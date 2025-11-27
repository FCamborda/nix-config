{
  config,
  pkgs,
  username,
  fullName,
  email,
  ...
}:

{
  imports = [
    ./dock
  ];

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit username fullName email; };
    users.${username} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          stateVersion = "23.11";
        };
        imports = [
          ../shared/home-manager.nix
        ];

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;

  # Replace your local.dock.entries with this one
  local.dock.entries = [
    { path = "/Applications/WezTerm.app/"; }
    { path = "/Applications/OrbStack.app/"; }
    { path = "/Applications/Google Chrome.app/"; }

    { path = "/System/Applications/System Settings.app/"; }

    {
      path = "${config.users.users.${username}.home}/Downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];
}
