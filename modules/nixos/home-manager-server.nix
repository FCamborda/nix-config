{
  username,
  fullName,
  email,
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
        imports = [
          ../core/home-manager.nix
          ../core/packages.nix
        ];
      };
  };
}
