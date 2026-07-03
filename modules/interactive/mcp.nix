{
  config,
  pkgs,
  ...
}:

let
  guardiansBin = "${config.home.homeDirectory}/git/guardians/dist/bin";

  gitlabMcp = pkgs.writeShellScriptBin "gitlab-mcp-wrapper" ''
    export GITLAB_MCP_TOKEN=$(security find-generic-password -s "gitlab-mcp" -a "$USER" -w)
    export GITLAB_MCP_URL=https://git.my-lab.com
    exec ${guardiansBin}/gitlab-mcp "$@"
  '';
in
{
  home.packages = [ gitlabMcp ];

  home.sessionPath = [ guardiansBin ];

  # Claude Code CLI
  home.file.".claude/settings.json".text = builtins.toJSON {
    mcpServers = {
      gitlab = {
        type = "stdio";
        command = "${gitlabMcp}/bin/gitlab-mcp-wrapper";
      };
    };
  };

  # Zed Agent
  programs.zed-editor.userSettings.context_servers = {
    gitlab = {
      command = "${gitlabMcp}/bin/gitlab-mcp-wrapper";
      args = [ ];
      env = { };
    };
  };
}
