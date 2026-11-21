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
          "nix-switch" = "sudo nixos-rebuild switch --flake .#${hostname}";
        };

        imports = [
          ../core/home-manager.nix
          ../core/packages.nix
          ../interactive/home-manager.nix
          ../interactive/packages.nix
        ];
      };
  };
}
