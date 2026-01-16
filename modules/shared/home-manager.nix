{
  pkgs,
  lib,
  email,
  fullName,
  config,
  ...
}:

{
  home.sessionVariables = {
    FZF_CTRL_T_COMMAND = "fd --type f";
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/.local/share/bin"
  ];

  # Create skhd config file
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

  # Create empty directory sockets/
  home.file.".ssh/sockets/.keep".text = "";

  programs = {
    zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "elixir"
      ];
      userSettings = {
        # Editor Settings
        vim_mode = true;
        relative_line_numbers = true;

        # Tab/File Settings
        preview_tabs.enabled = false;
        remove_trailing_whitespace_on_save = true;
        ensure_final_newline_on_save = true;
        # LLM
        agent = {
          default_profile = "ask";
          default_model = {
            model = "gemini-2.5-flash";
            provider = "google";
          };
        };
        languages = {
          Python = {
            language_servers = [ "basedpyright" ];
            formatter = {
              external = {
                command = "ruff";
                arguments = [
                  "format"
                  "--stdin-filename"
                  "{buffer_path}"
                ];
              };
            };
            format_on_save = "on";
          };
          Nix = {
            language_servers = [
              "nil"
              "!nixd"
            ];
            formatter = {
              external = {
                command = "nixfmt";
              };
            };
          };
        };
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      settings = {
        aliases = {
          st = "status";
          overwrite = "commit --no-edit --amend";
          init.defaultBranch = "main";
          pull.rebase = true;
          core = {
            editor = "vim";
            autocrlf = "input";
          };
          push.autosetupremote = true;
          rebase.autoStash = true;
          userName = fullName;
          userEmail = email;
        };
      };
      lfs = {
        enable = true;
      };
    };

    neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = ''
        " General Settings
        set clipboard=unnamed,unnamedplus
        set number

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

        set relativenumber
        set cursorline
      '';
    };

    ssh = {
      enable = true;
      # This will correctly populate the module's own hardcoded "Host *" block.
      # Note the values are booleans, strings, and integers as required by the module.
      forwardAgent = false;
      serverAliveInterval = 60;
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%h-%p";
      controlPersist = "10m";

      # Part 2: Use extraConfig to inject the settings that are NOT available
      # as top-level options, like the essential "IdentitiesOnly".
      extraConfig = ''
        IdentitiesOnly no
        IdentityAgent /Users/franco/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    # Shared shell configuration
    zsh = {
      enable = true;
      autocd = false;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        tree = "eza --tree";
        diff = "difft";
        "nix-switch" = "sudo darwin-rebuild switch --flake .#aarch64-darwin";
        "dns-flush" = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
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

        # Remove history data we don't want to see
        export HISTIGNORE="pwd:ls:cd"

        # nix shortcuts
        shell() {
            nix-shell '<nixpkgs>' -A "$1"
        }

        eval "$(zoxide init zsh --cmd cd)"
      '';
    };
  };
}
