{ config, lib, pkgs, ... }:

{
  home.username = "spcpolice";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    aerospace
    lazygit
    ripgrep
    fzf
    fd
    eza
    bat
    raycast
    _1password-gui
    opencode
    brave
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
        split-divider-color = "#FFF222";
        window-decoration = "none";
        keybind = [
          "ctrl+cmd+h=goto_split:left"
          "ctrl+cmd+j=goto_split:down"
          "ctrl+cmd+k=goto_split:up"
          "ctrl+cmd+l=goto_split:right"
          "ctrl+cmd+m=toggle_split_zoom"
          "ctrl+cmd+shift+h=resize_split:left,250"
          "ctrl+cmd+shift+l=resize_split:right,250"
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

  programs.git.settings = {
      enable = true;
      user.name = "spacepolice10";
      user.email = "naysayer@hey.com";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.activation.cloneLazyVim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ~/.config/nvim ]; then
      git clone https://github.com/LazyVim/starter ~/.config/nvim
    fi
  '';
}
