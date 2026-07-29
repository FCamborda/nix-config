{
  description = "Nix flake for macOS (nix-darwin) and NixOS systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    darwin.url = "github:LnL7/nix-darwin";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew/3cae36b3a17b09a66435291619dce8cf2c4728ca";
    };
    # Pinned close to nix-homebrew's own rev (Oct 2025) above, rather than
    # floating to HEAD, since the patched `brew` it vendors and these tap
    # checkouts need to be roughly version-matched — too large a gap between
    # them breaks cask/formula Ruby DSL parsing ("wrong number of arguments").
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle/a3265c84b232e13048ecbf6fc18a2eedfadbeb08";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core/6590d53609890ed71c70c69eac35e737fb4aab3b";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask/aa6169ec304db7a44c7b194c1099aa8886946cb4";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    let
      # ============================================================
      # USER CONFIGURATION
      # New developers: update these values for your own setup
      # ============================================================
      userConfig = {
        username = "franco";
        fullName = "Franco Camborda";
        email = "44851835+FCamborda@users.noreply.github.com";
      };

      # Helper function to create a darwin system
      mkDarwin =
        {
          system ? "aarch64-darwin",
          hostname,
          extraModules ? [ ],
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = userConfig // {
            inherit hostname;
          };
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = userConfig.username;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
          ]
          ++ extraModules;
        };

      # Helper function to create a NixOS system
      mkNixOS =
        {
          system ? "x86_64-linux",
          hostname,
          hostPath,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = userConfig // {
            inherit hostname;
          };
          modules = [
            hostPath
            home-manager.nixosModules.home-manager
          ]
          ++ extraModules;
        };
    in
    {
      # ============================================================
      # macOS CONFIGURATIONS
      # Apply with: darwin-rebuild switch --flake .#<hostname>
      # ============================================================
      darwinConfigurations."infrastructure-macbook" = mkDarwin {
        hostname = "infrastructure-macbook";
      };

      # ============================================================
      # NixOS CONFIGURATIONS - Desktop
      # Apply with: sudo nixos-rebuild switch --flake .#<hostname>
      # ============================================================
      nixosConfigurations."nixos-workstation" = mkNixOS {
        hostname = "nixos-workstation";
        hostPath = ./hosts/nixos;
      };

      # ============================================================
      # NixOS CONFIGURATIONS - Servers / CI
      # Headless systems without desktop environment
      # ============================================================
      nixosConfigurations."nixos-ci" = mkNixOS {
        hostname = "nixos-ci";
        hostPath = ./hosts/nixos-ci;
      };
    };
}
