{
  pkgs,
  lib,
  ...
}:

let
  name = "Franco Camborda";
  user = "franco";
  email = "f.camborda@outlook.com";
in
{
  # Add this block to declaratively create the skhd config file
  home.file.".config/skhd/skhdrc".text = ''
    #--------------------------------------------------
    # App Launchers
    #--------------------------------------------------

    # Launch WezTerm with Ctrl + Option + T
    ctrl + alt - t : open -a "WezTerm"

    #--------------------------------------------------
    # Screenshots (using built-in macOS tool)
    #--------------------------------------------------

    # Capture a selected area to a file on the Desktop
    cmd + shift - 4 : /usr/sbin/screencapture -i ~/Desktop/Screen-$(date +%Y-%m-%d-%H%M%S).png

    # Capture a selected area directly to the clipboard
    cmd + ctrl + shift - 4 : /usr/sbin/screencapture -ic

    # Capture the entire screen directly to the clipboard (without sound)
    cmd + ctrl + shift - 3 : /usr/sbin/screencapture -cx
  '';
  programs = {
    # Shared shell configuration
    zsh = {
      enable = true;
      autocd = false;
      shellAliases = {
        ll = "ls -l";
        "nix-switch" = "sudo darwin-rebuild switch --flake .#aarch64-darwin";
      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
        }
      ];

      initContent = lib.mkBefore ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi

        # Define variables for directories
        export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
        export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
        export PATH=$HOME/.local/share/bin:$PATH

        # Remove history data we don't want to see
        export HISTIGNORE="pwd:ls:cd"

        # nix shortcuts
        shell() {
            nix-shell '<nixpkgs>' -A "$1"
        }

        # Use difftastic, syntax-aware diffing
        alias diff=difft

        # Always color ls and group directories
        alias ls='ls --color=auto'

        eval "$(zoxide init zsh --cmd cd)"
      '';
    };

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
      };
      aliases = {
        st = "status";
        overwrite = "commit --no-edit --amend";
      };
    };

    neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = ''
        " General Settings
        set number
        set relativenumber

        set cursorline
        set scrolloff=3
        set hidden

        " Searching
        set incsearch
        set ignorecase
        set smartcase

        " Whitespace rules
        set tabstop=4
        set shiftwidth=4
        set softtabstop=4
        set expandtab
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    ssh = {
      enable = true;
      includes = [
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/config_external")
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/config_external")
      ];
      matchBlocks = {
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/home/${user}/.ssh/id_github")
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/Users/${user}/.ssh/id_github")
          ];
        };
      };
    };
  };
}
