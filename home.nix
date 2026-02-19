{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "spcpolice";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    aerospace
    ripgrep
    fzf
    fd
    eza
    bat
    tailspin
    raycast
    _1password-cli
    _1password-gui
  ];

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      font-size = 15;
      font-family = "FiraCode Nerd Font";
      cursor-style = "block";
      unfocused-split-opacity = 0.88;
      split-divider-color = "#222222";
      window-decoration = "none";
      keybind = [
        "ctrl+cmd+h=goto_split:left"
        "ctrl+cmd+j=goto_split:down"
        "ctrl+cmd+k=goto_split:up"
        "ctrl+cmd+l=goto_split:right"
        "ctrl+cmd+m=toggle_split_zoom"
        "ctrl+cmd+shift+h=resize_split:left,360"
        "ctrl+cmd+shift+l=resize_split:right,360"
        "ctrl+cmd+shift+k=resize_split:up,225"
        "ctrl+cmd+shift+j=resize_split:down,225"
      ];
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza -a";
      ll = "eza -l";
      la = "eza -TL 2 -a --icons";
      tree = "eza --tree";
      vi = "nvim";
      grep = "rg";
      cd = "z";
      flake-update = "sudo nix flake update --flake /etc/nix-darwin";
      nix-rebuild = "sudo nix run nix-darwin -- switch --flake /etc/nix-darwin#$(hostname -s)";
    };

    initContent = ''
      # Enhanced fzf function with preview and cd
      f() {
        local file
        file=$(fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null' --height 40% --layout=reverse)
        [ -n "$file" ] && cd "$(dirname "$file")"
      }

      # Auto-activate nix-darwin environment
      if [ -f /etc/nix-darwin/activate ]; then
        source /etc/nix-darwin/activate
      fi
    '';

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "dracula";
      editor.auto-format = true;
      editor.line-number = "relative";
      editor.file-picker.hidden = false;
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "bar";
      };
      keys.normal = {
        "C-s" = ":w";
        "C-r" = ":reload-all";
      };
      keys.insert = {
        "C-s" = [
          ":w"
          "normal_mode"
        ];
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
    ];
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-plugins "cpu-usage ram-usage time"
          set -g @dracula-show-flags true
          set -g @dracula-show-left-icon session
        '';
      }
    ];
  };

  programs.git = {
    enable = true;
    ignores = [ ".direnv" ];
    settings = {
      user.name = "spacepolice10";
      user.email = "naysayer@hey.com";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        name = "dracula";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
