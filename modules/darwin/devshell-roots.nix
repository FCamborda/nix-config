{ config, ... }:

let
  # The daily nix-gc (nix-gc.nix, 11:00) deleted the dev shell: nothing rooted it, so every
  # new applications worktree downloaded rustc, LLVM and the rest again, for hours on a slow
  # connection (2026-11-04/05). This agent builds the dev shell of the repository's origin/main
  # into a profile, which is a GC root, half an hour before the GC. nix print-dev-env builds
  # what `nix develop` would without running the shell's hook. The checkout is shallow, so the
  # flake is read with shallow=1. nix-gc prunes this profile's old generations like the others.
  nix = "/nix/var/nix/profiles/default/bin/nix";
  repo = "${config.home.homeDirectory}/git/applications";
  profile = "${config.home.homeDirectory}/.local/state/nix/profiles/devshell";
in
{
  launchd.agents.devshell-root = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          rev=$(/usr/bin/git -C ${repo} rev-parse refs/remotes/origin/main) || exit 1
          ${nix} --extra-experimental-features "nix-command flakes" print-dev-env \
            --profile ${profile} "git+file://${repo}?rev=$rev&shallow=1" >/dev/null
        ''
      ];
      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 30;
        }
      ];
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/devshell-root.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/devshell-root.log";
    };
  };
}
