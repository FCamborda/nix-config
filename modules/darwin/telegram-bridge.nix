{ config, pkgs, ... }:

let
  # Cloned manually and pinned to a tagged release (not `main`) — see
  # /Users/franco/.local/share/claude-code-telegram. Not built via Nix
  # (no poetry2nix in this repo yet); a plain venv (pyproject.toml's build
  # backend is poetry-core, which pip understands natively — no poetry CLI
  # needed) owns the install there, same "external checkout, thin nix
  # wrapper" shape as gitlabMcp in modules/interactive/mcp.nix.
  bridgeDir = "${config.home.homeDirectory}/.local/share/claude-code-telegram";

  telegramBridge = pkgs.writeShellScriptBin "claude-telegram-bridge" ''
    export TELEGRAM_BOT_TOKEN=$(security find-generic-password -s "telegram-bridge-mac" -a "$USER" -w)
    export TELEGRAM_BOT_USERNAME=$(security find-generic-password -s "telegram-bridge-mac-username" -a "$USER" -w)
    export ALLOWED_USERS=$(security find-generic-password -s "telegram-bridge-mac-allowed-users" -a "$USER" -w)
    export APPROVED_DIRECTORY="${config.home.homeDirectory}/git"
    # Project Threads: one Telegram forum topic per repo (see
    # ~/.local/share/claude-code-telegram/config/projects.yaml), each with
    # its own concurrent session — the fix for "one slow linear chat" that
    # doesn't require a third-party orchestrator.
    export ENABLE_PROJECT_THREADS="true"
    export PROJECT_THREADS_MODE="private"
    export PROJECTS_CONFIG_PATH="${bridgeDir}/config/projects.yaml"
    # launchd agents start with CWD=/ by default, and the bot's DATABASE_URL
    # default (sqlite:///data/bot.db) is a *relative* path — under CWD=/ that
    # resolves to /data/bot.db, which is on macOS's read-only system volume.
    # Pin both explicitly rather than relying on CWD.
    export DATABASE_URL="sqlite:///${bridgeDir}/data/bot.db"
    mkdir -p "${bridgeDir}/data"
    cd ${bridgeDir}
    exec ${bridgeDir}/.venv/bin/claude-telegram-bot
  '';
in
{
  home.packages = [
    pkgs.python313
    telegramBridge
  ];

  launchd.agents.claude-telegram-bridge = {
    enable = true;
    config = {
      ProgramArguments = [ "${telegramBridge}/bin/claude-telegram-bridge" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/claude-telegram-bridge.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/claude-telegram-bridge.err.log";
    };
  };
}
