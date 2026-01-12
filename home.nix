{ config, lib, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
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





  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraConfig = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set breakindent
      set nowrap
      set hidden
      set noswapfile
      set nobackup
      set undofile
      set updatetime=250
      set timeoutlen=300
      set ignorecase
      set smartcase
      set signcolumn=yes
      set scrolloff=8
      set sidescrolloff=8
      set mouse=a
      set termguicolors
      let mapleader = " "
      let maplocalleader = "\\"

      colorscheme catppuccin
    '';
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-treesitter
      telescope-nvim
      telescope-fzf-native-nvim
      which-key-nvim
      nvim-autopairs
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      nvim-lspconfig
      gitsigns-nvim
      nvim-comment
      indent-blankline-nvim
    ];
  };

}
