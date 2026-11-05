{
  username,
  fullName,
  email,
  hostname,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit username fullName email; };
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
          # Fleet shortcuts: `ssh infra`, `ssh bao`, `ssh k3s` — the VMs sit
          # on the host's private bridge and are only reachable by
          # jumping through it (see the infra repo's README).
          matchBlocks = {
            "infra" = {
              hostname = "host.example.net";
              user = "franco";
            };
            "bao" = {
              hostname = "192.0.2.1";
              user = "franco";
              proxyJump = "infra";
            };
            "k3s" = {
              hostname = "192.0.2.1";
              user = "franco";
              proxyJump = "infra";
            };
            "s3 seaweed" = {
              hostname = "192.0.2.1";
              user = "franco";
              proxyJump = "infra";
            };
          };
          extraConfig = ''
            IdentitiesOnly no
            IdentityAgent ${config.home.homeDirectory}/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
          '';
        };

        # Create empty directory for SSH control sockets
        home.file.".ssh/sockets/.keep".text = "";

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
