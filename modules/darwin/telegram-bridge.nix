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
