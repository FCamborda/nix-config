{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Shell enhancements
    eza
    fd
    ripgrep
    difftastic

    # Signing & local dev
    gnupg
    mkcert

    # Editor - Zed is our default, but feel free to swap for your preference:
    # - vscode (VS Code open source build)
    # - vscodium (VS Code without telemetry)
    # - cursor (AI-powered editor) - install via Homebrew on macOS
    zed-editor

    # Containers & local K8s development
    podman
    minikube
    kind

    # Secrets management
    openbao
  ];
}
