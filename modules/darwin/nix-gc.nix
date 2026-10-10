{ pkgs, username, ... }:

let
  # Runs as root (launchd daemon) so it can prune the system profile too; the
  # per-user disk-cleanup agent can't touch root-owned profiles. nix.gc isn't
  # available because nix.enable = false.
  #
  # Retention: a generation is kept if it is among the 7 latest OR younger than
  # 7 days. The current generation is never deleted (nix-env refuses anyway).
  gcScript = pkgs.writeShellScriptBin "nix-gc" ''
    set -uo pipefail
    keep_latest=7
    cutoff=$(( $(/bin/date +%s) - 7 * 86400 ))

    prune() {
      local profile=$1
      [ -e "$profile" ] || return 0
      local gens total doomed=()
      gens=$(${pkgs.nix}/bin/nix-env -p "$profile" --list-generations | ${pkgs.gawk}/bin/awk '{print $1}')
      total=$(echo "$gens" | ${pkgs.gawk}/bin/awk 'NF' | /usr/bin/wc -l)
      # Everything except the latest $keep_latest, oldest first.
      for gen in $(echo "$gens" | ${pkgs.gawk}/bin/awk -v n=$(( total - keep_latest )) 'NR <= n'); do
        local mtime
        mtime=$(/usr/bin/stat -f %m "$profile-$gen-link" 2>/dev/null) || continue
        [ "$mtime" -lt "$cutoff" ] && doomed+=("$gen")
      done
      if [ ''${#doomed[@]} -gt 0 ]; then
        echo "$profile: deleting generations ''${doomed[*]}"
        ${pkgs.nix}/bin/nix-env -p "$profile" --delete-generations "''${doomed[@]}"
      fi
    }

    prune /nix/var/nix/profiles/system
    prune /nix/var/nix/profiles/per-user/root/profile
    prune /Users/${username}/.local/state/nix/profiles/home-manager
    prune /Users/${username}/.local/state/nix/profiles/profile

    ${pkgs.nix}/bin/nix-store --gc
  '';
in
{
  launchd.daemons.nix-gc = {
    serviceConfig = {
      ProgramArguments = [ "${gcScript}/bin/nix-gc" ];
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 11;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };
}
