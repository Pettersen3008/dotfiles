{
  description = "Pettersen dev setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
    let
      lib = nixpkgs.lib;
      username = "pettersen";
      darwinHosts = {
        mbp = "aarch64-darwin";
        # Add more hosts here, e.g.:
        # mbp-work = "aarch64-darwin";
      };

      mkDarwin = hostname: system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./darwin-configuration.nix
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
          {
            networking.hostName = hostname;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users.${username} = import ./home.nix;
          }
          ];
          specialArgs = { inherit username hostname; };
        };

      mkHome = { system, module }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ module ];
          extraSpecialArgs = { inherit username; };
        };
    in {
      darwinConfigurations = lib.mapAttrs mkDarwin darwinHosts;

      # Shared home-manager roots for non-darwin usage.
      homeConfigurations = {
        "${username}@arch" = mkHome {
          system = "x86_64-linux";
          module = ./home-linux.nix;
        };
      };
    };
}
