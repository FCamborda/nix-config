{
  config,
  fullName,
  email,
  githubEmail,
  ...
}:

{
  home.stateVersion = "23.11";
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  # Enable flakes/nix-command for plain `nix` CLI invocations without needing
  # --extra-experimental-features every time. Needed on darwin in particular,
  # since nix-darwin's own nix.enable = false means no system-level nix.conf
  # manages this.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  programs.git = {
    enable = true;
    userName = fullName;
    userEmail = email;
    # Repositories with a GitHub remote use githubEmail instead (git 2.36+ hasconfig): GitHub and
    # GitLab each attribute a commit only to an address the account there knows.
    includes = map (url: {
      condition = "hasconfig:remote.*.url:${url}";
      contents.user.email = githubEmail;
    }) [
      # `**` spans directories only next to a `/`; after the scp-style `:` it would stop at one.
      "git@github.com:*/**"
      "https://github.com/**"
    ];
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "vim";
      push.autosetupremote = true;
      alias = {
        st = "status";
        overwrite = "commit --no-edit --amend";
        cleanup-preview = "!git fetch -p && git branch -vv | grep ': gone]'";
        cleanup = "!git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";
        cleanup-force = "!git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D";
      };
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      set clipboard=unnamed,unnamedplus
      set number
      set scrolloff=3
      set hidden
      set incsearch
      set ignorecase
      set smartcase
      set tabstop=4
      set shiftwidth=4
      set softtabstop=4
      set expandtab
    '';
  };
}
