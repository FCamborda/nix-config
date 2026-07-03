{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./mcp.nix ];
  home.sessionVariables = {
    FZF_CTRL_T_COMMAND = "fd --type f";
    VAULT_ADDR = "https://openbao.my-lab.com";
  };

  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "elixir"
    ];
    userSettings = {
      vim_mode = true;
      relative_line_numbers = true;
      agent = {
        default_profile = "ask";
        default_model = {
          provider = "google";
          model = "gemini-2.5-flash";
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
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

      # SSH into a my-lab host via OpenBao cert (re-login if token expired)
      mylab-ssh() {
          local pubkey="''${2:-$HOME/.ssh/id_ed25519.pub}"
          # Drop any stale host key first — fleet VMs are reprovisioned often (new
          # host key, reused IPs), which otherwise hard-fails the connection with
          # "REMOTE HOST IDENTIFICATION HAS CHANGED". accept-new then trusts the
          # fresh key without an interactive prompt.
          ssh-keygen -R "''${1##*@}" >/dev/null 2>&1 || true
          # Pin the private key to the matching pubkey — without -private-key-path,
          # `bao ssh` defaults to ~/.ssh/id_rsa and auth fails with "invalid format".
          bao ssh -role=personal-access -mode=ca -mount-point=ssh \
              -public-key-path "$pubkey" -private-key-path "''${pubkey%.pub}" \
              "$1" -o StrictHostKeyChecking=accept-new
      }

      eval "$(zoxide init zsh --cmd cd)"
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
