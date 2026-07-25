{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core CLI tools
    bat
    btop
    coreutils
    curl
    wget
    jq
    yq-go
    htop
    killall
    unzip
    zip

    # Version control
    git
    glab
    openssh

    # K8s tooling (useful for CI/CD deployments)
    kubectl
    kubernetes-helm

    # Nix tooling
    nil
    nixfmt-rfc-style
  ];
}
