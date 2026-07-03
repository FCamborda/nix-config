{
  description = "Nix flake for macOS (nix-darwin) and NixOS systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    darwin.url = "github:LnL7/nix-darwin";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
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
