{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "spcpolice";
  home.homeDirectory = "/home/spcpolice";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    ripgrep
    fzf
    fd
    eza
    bat
    tailspin
    _1password-cli
    nerd-fonts.fira-code
    # raycast — macOS only, no Linux equivalent via Nix
    # _1password-gui — install separately if needed (1password.com/downloads/linux)
    # opencode — check nixpkgs availability for aarch64-linux before enabling
  ];

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty; # on Linux always use pkgs.ghostty (not ghostty-bin)
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      font-size = 15;
      font-family = "FiraCode Nerd Font";
      cursor-style = "block";
      unfocused-split-opacity = 0.88;
      split-divider-color = "#222222";
      window-decoration = "none";
      window-padding-balance = false;
      # macos-option-as-alt — macOS only, removed
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
      vi = "hx";
      grep = "rg";
      cd = "z";
      flake-update = "sudo nix flake update --flake /etc/nixos";
      nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };

    initContent = ''
      # Report current directory to tmux via OSC 7 for #{pane_current_path}
      autoload -Uz add-zsh-hook
      _osc7_cwd() { printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"; }
      add-zsh-hook chpwd _osc7_cwd
      _osc7_cwd

      # Enhanced fzf function with preview and cd
      f() {
        local file
        file=$(fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null' --height 40% --layout=reverse)
        [ -n "$file" ] && cd "$(dirname "$file")"
      }

      source "${config.xdg.configHome}/zsh/mux.zsh"
    '';

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "base16_transparent";
      editor.auto-format = true;
      editor.line-number = "relative";
      editor.soft-wrap.enable = true;
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
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs.tmuxPlugins; [ sensible ];
    extraConfig = ''
      set -g default-command "${pkgs.zsh}/bin/zsh"

      set -g automatic-rename off
      set -g allow-rename off

      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      set -g status-style 'bg=black fg=white'
      set -g status-left '[#S] '
      set -g status-right '%H:%M %d-%b'
      set -g window-status-current-style 'fg=yellow bold'
    '';
  };

  xdg.configFile."zsh/mux.zsh".text = ''
        # mx-cc: claude (left) | empty terminal (top-right) / hx (bottom-right)
        mx-cc() {
          local dir name
          if [ -n "''${1}" ]; then
            dir=$(zoxide query "''${1}") || return 1
            name="''${1}"
          else
            dir="$PWD"
            name=$(basename "$dir")
          fi
          if [ -z "$TMUX" ]; then
            tmux new-session -s "$name" -n "$name" -c "$dir" \; \
              split-window -h -c "$dir" \; \
              split-window -v -c "$dir" \; \
              send-keys "hx ." Enter \; \
              select-pane -U \; \
              select-pane -L \; \
              send-keys "claude" Enter \; \
              select-pane -R
            return
          fi
          tmux rename-window "$name"
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

        # mx-agents: 4 claude instances in a 2x2 grid
        mx-agents() {
          local dir name
          if [ -n "''${1}" ]; then
            dir=$(zoxide query "''${1}") || return 1
            name="''${1}"
          else
            dir="$PWD"
            name=$(basename "$dir")
          fi
          if [ -z "$TMUX" ]; then
            tmux new-session -s "$name" -n "$name" -c "$dir" \; \
              send-keys "claude" Enter \; \
              split-window -h -c "$dir" \; \
              send-keys "claude" Enter \; \
              split-window -v -c "$dir" \; \
              send-keys "claude" Enter \; \
              select-pane -L \; \
              split-window -v -c "$dir" \; \
              send-keys "claude" Enter
            return
          fi
          tmux rename-window "$name"
          tmux kill-pane -a
          tmux send-keys "cd $(printf '%q' "$dir") && clear" Enter
          tmux send-keys "claude" Enter
          tmux split-window -h -c "$dir"
          tmux send-keys "claude" Enter
          tmux split-window -v -c "$dir"
          tmux send-keys "claude" Enter
          tmux select-pane -L
          tmux split-window -v -c "$dir"
          tmux send-keys "claude" Enter
        }
  '';

  programs.difftastic = {
    enable = true;
    git.enable = true;
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
        activeBorderColor = [
          "#FF79C6"
          "bold"
        ];
        inactiveBorderColor = [ "#BD93F9" ];
        searchingActiveBorderColor = [
          "#8BE9FD"
          "bold"
        ];
        optionsTextColor = [ "#6272A4" ];
        selectedLineBgColor = [ "#6272A4" ];
        inactiveViewSelectedLineBgColor = [ "bold" ];
        cherryPickedCommitFgColor = [ "#6272A4" ];
        cherryPickedCommitBgColor = [ "#8BE9FD" ];
        markedBaseCommitFgColor = [ "#8BE9FD" ];
        markedBaseCommitBgColor = [ "#F1FA8C" ];
        unstagedChangesColor = [ "#FF5555" ];
        defaultFgColor = [ "#F8F8F2" ];
      };
      git.pagers = [
        {
          colorArg = "always";
          externalDiffCommand = "difft --color=always";
        }
      ];
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
