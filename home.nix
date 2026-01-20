{ config, lib, pkgs, inputs, ... }:

{
  home.username = "spcpolice";
  home.stateVersion = "25.11";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim".source = ./nvim;

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
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.git = {
    enable = true;
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
}
