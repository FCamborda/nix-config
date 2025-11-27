{ pkgs }:

with pkgs;
[
  # Core Utilities & Replacements
  bat
  btop
  coreutils
  fd
  jq
  ripgrep
  tree
  wget

  gemini-cli

  # Essential Tools
  openssh
  gnupg
  killall
  unzip
  zip
  ## CA - WebDeveloment
  mkcert

  # Software development
  zed-editor

  # K8s
  kubectl
  kubernetes-helm
  # Nix LSP
  nil
]
