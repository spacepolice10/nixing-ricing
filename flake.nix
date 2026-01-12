{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
