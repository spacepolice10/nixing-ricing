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
    ripgrep
    fzf
    fd
    eza
    bat
    tailspin
    raycast
    _1password-cli
    _1password-gui
    nerd-fonts.fira-code
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
      window-padding-balance = false;
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
      vi = "hx";
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
    plugins = with pkgs.tmuxPlugins; [
      sensible
      cpu
      battery
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_cpu_text " #{cpu_percentage}"
          set -g @catppuccin_battery_text " #{battery_percentage}"
          set -g @catppuccin_battery_icon "#{battery_icon} "
        '';
      }
    ];
    extraConfig = ''
      # Prevent tmux from overriding explicit window renames
      set -g automatic-rename off

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

      # Status line (set after catppuccin plugin loads)
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_cpu}"
      set -ag status-right "#{E:@catppuccin_status_battery}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
    '';
  };

  xdg.configFile."zsh/mux.zsh".text = ''
    # mx-cc: claude (left) | empty terminal (top-right) / hx (bottom-right)
    mx-cc() {
      local dir name
      if [ -n "''${1}" ]; then
        dir=$(zoxide query "''${1}") || return 1
      else
        dir="$PWD"
      fi
      name=$(basename "$dir")
      if [ -z "$TMUX" ]; then
        tmux new-session -s "$name" -c "$dir" \; \
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

    # mx-cx: codex (left) | empty terminal (top-right) / hx (bottom-right)
    mx-cx() {
      local dir name
      if [ -n "''${1}" ]; then
        dir=$(zoxide query "''${1}") || return 1
      else
        dir="$PWD"
      fi
      name=$(basename "$dir")
      if [ -z "$TMUX" ]; then
        tmux new-session -s "$name" -c "$dir" \; \
          split-window -h -c "$dir" \; \
          split-window -v -c "$dir" \; \
          send-keys "hx ." Enter \; \
          select-pane -U \; \
          select-pane -L \; \
          send-keys "codex" Enter \; \
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
      tmux send-keys "codex" Enter
      tmux select-pane -R
    }

    # mx-cc-agents: two claude instances side by side
    mx-cc-agents() {
      local dir name
      if [ -n "''${1}" ]; then
        dir=$(zoxide query "''${1}") || return 1
      else
        dir="$PWD"
      fi
      name=$(basename "$dir")
      if [ -z "$TMUX" ]; then
        tmux new-session -s "$name" -c "$dir" \; \
          send-keys "claude" Enter \; \
          split-window -h -c "$dir" \; \
          send-keys "claude" Enter
        return
      fi
      tmux rename-window "$name"
      tmux kill-pane -a
      tmux send-keys "cd $(printf '%q' "$dir") && clear" Enter
      tmux send-keys "claude" Enter
      tmux split-window -h -c "$dir"
      tmux send-keys "claude" Enter
    }

    # mx-cx-agents: two codex instances side by side
    mx-cx-agents() {
      local dir name
      if [ -n "''${1}" ]; then
        dir=$(zoxide query "''${1}") || return 1
      else
        dir="$PWD"
      fi
      name=$(basename "$dir")
      if [ -z "$TMUX" ]; then
        tmux new-session -s "$name" -c "$dir" \; \
          send-keys "codex" Enter \; \
          split-window -h -c "$dir" \; \
          send-keys "codex" Enter
        return
      fi
      tmux rename-window "$name"
      tmux kill-pane -a
      tmux send-keys "cd $(printf '%q' "$dir") && clear" Enter
      tmux send-keys "codex" Enter
      tmux split-window -h -c "$dir"
      tmux send-keys "codex" Enter
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
      git.paging = {
        colorArg = "always";
        externalDiffCommand = "difft --color=always";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # programs.aerospace = {
  #   enable = true;
  #   launchd.enable = true;
  #   settings = {
  #     after-login-command = [ ];
  #     after-startup-command = [ ];
  #     enable-normalization-flatten-containers = true;
  #     enable-normalization-opposite-orientation-for-nested-containers = true;
  #     accordion-padding = 0;
  #     default-root-container-layout = "tiles";
  #     default-root-container-orientation = "auto";
  #     on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
  #     automatically-unhide-macos-hidden-apps = false;
  #
  #     key-mapping.preset = "qwerty";
  #
  #     gaps = {
  #       inner.horizontal = 0;
  #       inner.vertical = 0;
  #       outer.left = 0;
  #       outer.bottom = 0;
  #       outer.top = 0;
  #       outer.right = 0;
  #     };
  #
  #     mode.main.binding = {
  #       alt-slash = "layout tiles horizontal vertical";
  #       alt-comma = "layout accordion horizontal vertical";
  #       alt-shift-h = "move left";
  #       alt-shift-j = "move down";
  #       alt-shift-k = "move up";
  #       alt-shift-l = "move right";
  #       alt-ctrl-minus = "resize smart -50";
  #       alt-ctrl-equal = "resize smart +50";
  #       cmd-1 = "workspace 1";
  #       cmd-2 = "workspace 2";
  #       cmd-3 = "workspace 3";
  #       cmd-4 = "workspace 4";
  #       cmd-5 = "workspace 5";
  #       alt-shift-1 = "move-node-to-workspace 1";
  #       alt-shift-2 = "move-node-to-workspace 2";
  #       alt-shift-3 = "move-node-to-workspace 3";
  #       alt-shift-4 = "move-node-to-workspace 4";
  #       alt-shift-5 = "move-node-to-workspace 5";
  #       alt-shift-semicolon = "mode service";
  #     };
  #
  #     mode.service.binding = {
  #       esc = [
  #         "reload-config"
  #         "mode main"
  #       ];
  #       r = [
  #         "flatten-workspace-tree"
  #         "mode main"
  #       ];
  #       f = [
  #         "layout floating tiling"
  #         "mode main"
  #       ];
  #       backspace = [
  #         "close-all-windows-but-current"
  #         "mode main"
  #       ];
  #       alt-shift-h = [
  #         "join-with left"
  #         "mode main"
  #       ];
  #       alt-shift-j = [
  #         "join-with down"
  #         "mode main"
  #       ];
  #       alt-shift-k = [
  #         "join-with up"
  #         "mode main"
  #       ];
  #       alt-shift-l = [
  #         "join-with right"
  #         "mode main"
  #       ];
  #     };
  #   };
  # };
}
