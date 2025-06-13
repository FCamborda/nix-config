{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  dockutil
  emacs-unstable
  skhd
  nil
  nixfmt-rfc-style
  _1password-cli
]
