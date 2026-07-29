{ config, pkgs, ... }:

let
  # --delete-older-than (not -d) so a rollback window survives automated runs.
  # docker prune only touches unused images/containers, so it's safe to run
  # unattended even while OrbStack has active containers.
  cleanupScript = pkgs.writeShellScriptBin "disk-cleanup" ''
    set -uo pipefail
    if /usr/local/bin/docker info >/dev/null 2>&1; then
      /usr/local/bin/docker system prune -af
    fi
    ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 30d
  '';
in
{
  launchd.agents.disk-cleanup = {
    enable = true;
    config = {
      ProgramArguments = [ "${cleanupScript}/bin/disk-cleanup" ];
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 11;
          Minute = 0;
        }
      ];
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/disk-cleanup.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/disk-cleanup.err.log";
    };
  };
}
