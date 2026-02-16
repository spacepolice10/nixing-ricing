# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Apply

```bash
# Rebuild and switch to new configuration
darwin-rebuild switch --flake /etc/nix-darwin

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update --flake /etc/nix-darwin

# Format nix files
nixfmt /etc/nix-darwin/*.nix
```

## Architecture

This is a nix-darwin flake configuration for a personal aarch64-darwin machine (user: `spcpolice`).

**flake.nix** — Entry point. Defines inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew) and composes all modules into a single `darwinConfigurations."spcpolice"`. Base config enables unfree packages and flakes.

**darwin-configuration.nix** — System-level macOS settings: Dock behavior, keyboard remapping (CapsLock→Escape), trackpad settings, and Homebrew casks (GUI apps like Firefox, Claude Code). Homebrew is managed declaratively with auto-update and `zap` cleanup.

**home.nix** — User environment via home-manager. Contains:
- Nix packages (`home.packages`): CLI tools and GUI apps installed via nixpkgs
- Program modules (`programs.*`): declarative config for shell (zsh), terminal (ghostty), editor (helix), git, gh, lazygit, direnv, zoxide, starship

The split is: system/macOS defaults go in `darwin-configuration.nix`, user tools and dotfiles go in `home.nix`.

## Conventions

- Nix files use `nixfmt-rfc-style` formatting
- Preferred editor is Helix (not neovim)
- Theme preference: dracula
- GUI apps go in `homebrew.casks`, CLI tools go in `home.packages` or `programs.*`
- Use `programs.*` home-manager modules when available instead of raw packages (they provide declarative config)
