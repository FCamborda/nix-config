{ pkgs }:

with pkgs; [
  # Core Utilities & Replacements
  bat
  btop
  coreutils
  fd
  jq
  ripgrep
  tree
  wget

  # Essential Tools
  openssh
  gnupg
  killall
  unzip
  zip
]
