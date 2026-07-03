{ pkgs, ... }:

{
  # Networking
  networking.networkmanager.enable = true;

  # SSH server (key-only authentication)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Podman (rootless containers, Docker-compatible)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };

  # System packages available to all users
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
  ];
}
