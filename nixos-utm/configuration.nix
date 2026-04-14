# NixOS system configuration for UTM VM
#
# BEFORE USING THIS FILE:
#   1. Install NixOS in UTM using the aarch64 ISO
#   2. During/after install, nixos-generate-config creates hardware-configuration.nix
#   3. Copy this flake to /etc/nixos on the VM
#   4. Run: sudo nixos-rebuild switch --flake /etc/nixos#nixos
#
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ]; # auto-generated during NixOS install

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York"; # adjust as needed

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.spcpolice = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # CapsLock → Escape (replaces macOS system.keyboard.remapCapsLockToEscape)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "esc";
    };
  };

  # SSH server — useful for accessing the VM from macOS terminal
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
