{
  username,
  fullName,
  email,
  githubEmail,
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
        imports = [
          ../core/home-manager.nix
          ../core/packages.nix
        ];
      };
  };
}
