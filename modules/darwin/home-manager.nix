{
  username,
  fullName,
  email,
  githubEmail,
  hostname,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit username fullName email githubEmail; };
    users.${username} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        programs.zsh.shellAliases = {
          "nix-switch" = "sudo darwin-rebuild switch --flake .#${hostname}";
          "dns-flush" = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
        };

        programs.ssh = {
          enable = true;
          forwardAgent = false;
          serverAliveInterval = 60;
          controlMaster = "auto";
          controlPath = "~/.ssh/sockets/%r@%h-%p";
          controlPersist = "10m";
          # Host shortcuts that name private infrastructure live outside this public repository:
          # drop an ssh config file into ~/.ssh/config.d/ (e.g. one kept with that infrastructure).
          includes = [ "config.d/*" ];
          extraConfig = ''
            IdentitiesOnly no
            IdentityAgent ${config.home.homeDirectory}/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
          '';
        };

        # Create empty directory for SSH control sockets
        home.file.".ssh/sockets/.keep".text = "";
        # And the directory the ssh config includes private host shortcuts from
        home.file.".ssh/config.d/.keep".text = "";

        home.packages = [ pkgs.skhd ];

        home.file.".config/skhd/skhdrc".text = ''
          #--------------------------------------------------
          # App Launchers
          #--------------------------------------------------

          # Launch WezTerm with Ctrl + Option + T
          ctrl + alt - t : open -a "WezTerm"

          #--------------------------------------------------
          # Screenshots (using built-in macOS tool)
          #--------------------------------------------------

          # Capture a selected area to a file on the Desktop
          cmd + shift - 4 : /usr/sbin/screencapture -i ~/Desktop/Screen-$(date +%Y-%m-%d-%H%M%S).png

          # Capture a selected area directly to the clipboard
          cmd + ctrl + shift - 4 : /usr/sbin/screencapture -ic

          # Capture the entire screen directly to the clipboard (without sound)
          cmd + ctrl + shift - 3 : /usr/sbin/screencapture -cx
        '';

        # Windows-style Maximize on Ctrl+Option+Up; Rectangle's stock
        # Top Half / Maximize Height bindings are cleared to avoid clashing
        # with it. Everything else keeps Rectangle's built-in defaults.
        home.activation.rectangleSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          /usr/bin/defaults write com.knollsoft.Rectangle maximize -dict keyCode -int 126 modifierFlags -int 786432
          /usr/bin/defaults write com.knollsoft.Rectangle topHalf -dict
          /usr/bin/defaults write com.knollsoft.Rectangle maximizeHeight -dict
        '';

        imports = [
          ../core/home-manager.nix
          ../core/packages.nix
          ../interactive/home-manager.nix
          ../interactive/packages.nix
          ./telegram-bridge.nix
          ./disk-cleanup.nix
          ./devshell-roots.nix
        ];
      };
  };
}
