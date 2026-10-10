{ config, pkgs, ... }:

let
  # docker prune only touches unused images/containers, so it's safe to run
  # unattended even while OrbStack has active containers. Nix GC lives in the
  # root nix-gc daemon (nix-gc.nix) so it can also prune the system profile.
  cleanupScript = pkgs.writeShellScriptBin "disk-cleanup" ''
    set -uo pipefail
    if /usr/local/bin/docker info >/dev/null 2>&1; then
      /usr/local/bin/docker system prune -af
    fi
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
