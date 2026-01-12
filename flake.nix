{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nix-homebrew, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
        ];
      nixpkgs.config.allowUnfree = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
      ];

      # Ensure nix-darwin config persists after reboot
      system.activationScripts.fixNixPermissions.text = ''
        # Fix nix store permissions if needed
        if [ -d "/nix" ]; then
          chown -R spcpolice:staff /nix/store 2>/dev/null || true
        fi
      '';
  
    };
  in
  {
    # Build darwin flake using:
    darwinConfigurations."spcpolice" = nix-darwin.lib.darwinSystem {
      modules = [
      configuration
      ./darwin-configuration.nix
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "spcpolice";
          };
        }
        home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.spcpolice = { config, pkgs, lib, ... }:
                import ./home.nix { inherit config pkgs lib; };
              home-manager.backupFileExtension = "backup";
            }
       ];
    };
  };

}
