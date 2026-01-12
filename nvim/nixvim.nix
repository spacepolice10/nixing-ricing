{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      breakindent = true;
      wrap = false;
      hidden = true;
      swapfile = false;
      backup = false;
      undofile = true;
      updatetime = 250;
      timeoutlen = 300;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      scrolloff = 8;
      sidescrolloff = 8;
      mouse = "a";
      termguicolors = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        background = {
          light = "latte";
          dark = "mocha";
        };
        transparent_background = false;
      };
    };

    plugins = {
      lazy = {
        enable = true;
        plugins = [
          {
            pkg = pkgs.vimPlugins.lazy-nvim;
            settings = {
              spec = {
                pkgs.vimPlugins.LazyVim;
              };
              defaults = {
                lazy = false;
                version = false;
              };
              install = {
                colorscheme = [ "catppuccin" ];
              };
              performance = {
                rtp = {
                  disabled_plugins = [
                    "gzip"
                    "tarPlugin"
                    "tohtml"
                    "tutor"
                    "zipPlugin"
                  ];
                };
              };
            };
          }
        ];
      };

      treesitter = {
        enable = true;
        settings = {
          indent.enable = true;
          highlight.enable = true;
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      which-key = {
        enable = true;
      };

      nvim-autopairs = {
        enable = true;
      };

      nvim-cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
          ts_ls.enable = true;
          pylsp.enable = true;
          rust_analyzer.enable = true;
          gopls.enable = true;
        };
      };

      lint = {
        enable = true;
        lintersByFt = {
          nix = [ "nix" ];
          lua = [ "luacheck" ];
          python = [ "ruff" ];
          javascript = [ "eslint_d" ];
          typescript = [ "eslint_d" ];
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
            python = [ "black" ];
            javascript = [ "prettierd" ];
            typescript = [ "prettierd" ];
            javascriptreact = [ "prettierd" ];
            typescriptreact = [ "prettierd" ];
          };
        };
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "<C-t>";
          direction = "float";
        };
      };

      gitsigns = {
        enable = true;
      };

      comment = {
        enable = true;
      };

      indent-blankline = {
        enable = true;
      };

      mini = {
        enable = true;
        modules = {
          surround = {};
          pairs = {};
        };
      };
    };

    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      fzf
      nixfmt
      stylua
      black
      nodePackages.prettierd
      luacheck
      ruff
      eslint_d
    ];
  };
}