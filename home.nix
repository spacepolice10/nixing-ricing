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
      lua << EOF
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "--branch=stable",
          "https://github.com/folke/lazy.nvim.git",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { import = "lazyvim.plugins.extras.coding.mini-surround" },
          { import = "lazyvim.plugins.extras.editor.mini-files" },
          { import = "lazyvim.plugins.extras.editor.telescope" },
        },
        defaults = {
          lazy = false,
          version = false,
        },
        install = {
          colorscheme = { "catppuccin" },
        },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };

}
