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
    nerd-fonts.jetbrains-mono
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
      macos-option-as-alt = true;
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
      # Report current directory to tmux via OSC 7 for #{pane_current_path}
      autoload -Uz add-zsh-hook
      _osc7_cwd() { printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"; }
      add-zsh-hook chpwd _osc7_cwd
      _osc7_cwd

      # Tmux layout: claude (left) | empty terminal (top-right) / hx (bottom-right)
      mux-dev() {
        local dir
        if [ -n "''${1}" ]; then
          dir=$(zoxide query "''${1}") || return 1
        else
          dir="$PWD"
        fi
        tmux rename-window "$(basename "$dir")"
        tmux kill-pane -a
        tmux send-keys "cd $(printf '%q' "$dir") && clear" Enter
        tmux split-window -h -c "$dir"
        tmux split-window -v -c "$dir"
        tmux send-keys "hx ." Enter
        tmux select-pane -U
        tmux select-pane -L
        tmux send-keys "claude" Enter
        tmux select-pane -R
      }

      # Tmux layout: two claude instances side by side
      mux-dev-agents() {
        local dir
        if [ -n "''${1}" ]; then
          dir=$(zoxide query "''${1}") || return 1
        else
          dir="$PWD"
        fi
        tmux rename-window "$(basename "$dir")"
        tmux kill-pane -a
        tmux send-keys "cd $(printf '%q' "$dir") && clear" Enter
        tmux send-keys "claude" Enter
        tmux split-window -h -c "$dir"
        tmux send-keys "claude" Enter
      }

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
    prefix = "C-Space";
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
          set -g @dracula-plugins "cpu-usage ram-usage battery time"
          set -g @dracula-show-flags true
          set -g @dracula-show-left-icon session
          set -g @dracula-battery-label ""
        '';
      }
    ];
    extraConfig = ''
      set-option -g default-shell /bin/zsh

      # New windows/panes inherit current path
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # Switch windows with Alt+1-5 (no prefix)
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5

      # Switch panes with Alt+h,j,k,l (no prefix)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Dim inactive panes
      set -g window-style 'fg=colour244,bg=default'
      set -g window-active-style 'fg=colour255,bg=default'
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 0;
          y = 0;
        };
        decorations = "buttonless";
        option_as_alt = "Both";
      };
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 15.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
      };
    };
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
