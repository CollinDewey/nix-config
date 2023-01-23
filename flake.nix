{
  description = "Collin's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-22.11";
    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    nix-index-database = { # Wait for Mic92/nix-index-database#34
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:LegitMagic/nixos-generators/sd-aarch64-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, impermanence, sops-nix, nix-index-database, darwin, disko, home-manager, home-manager-stable, plasma-manager, android-nixpkgs, nixos-generators, ... }@inputs: {

    nixosConfigurations = {
      BURGUNDY = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./overlays/android-sdk.nix
          ./modules
          ./hosts/BURGUNDY/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/BURGUNDY/hardware-configuration.nix

          {
            modules = {
              plasma.enable = true;
              printing.enable = true;
              ssh.enable = true;
              virtualisation = {
                docker = true;
                libvirt = true;
                nvidia = true;
              };
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
          home-manager.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                android-nixpkgs.hmModule
                nix-index-database.hmModules.nix-index
                ./home
                ./home/android-sdk.nix

                # Computer Specific Config
                ./hosts/BURGUNDY/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                android-sdk.enable = true;
                communication.enable = true;
                cyber.enable = true;
                gaming.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "23.05";
            };
          }
        ];
      };

      TEAL = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/TEAL/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/TEAL/hardware-configuration.nix

          {
            modules = {
              plasma.enable = true;
              printing.enable = true;
              ssh.enable = true;
              virtualisation = {
                docker = true;
                libvirt = true;
                nvidia = true;
              };
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
          home-manager-stable.nixosModules.home-manager
          ./config/home.nix

          {

            home-manager.users.collin = {

              imports = [
                # Modules
                plasma-manager.homeManagerModules.plasma-manager
                nix-index-database.hmModules.nix-index
                ./home

                # Computer Specific Config
                ./hosts/TEAL/home.nix

                # User Specific Config
                ./users/collin/home.nix
              ];

              modules = {
                communication.enable = true;
                cyber.enable = true;
                gaming.enable = true;
                lock.enable = true;
                misc.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };

              home.stateVersion = "22.11";
            };
          }
        ];
      };

      VIRIDIAN = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/VIRIDIAN/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/VIRIDIAN/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
      };

      BROWN = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/BROWN/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
      };

      SCARLET = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/SCARLET/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
      };

      ESPORTS = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules

          # Specialized Hardware Configuration
          ./hosts/ESPORTS/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/esports
        ];
      };
    };

    darwinConfigurations = {
      COPPER = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./config
          ./config/home.nix
          ./hosts/COPPER/configuration.nix
          ./modules/zsh.nix
          {
            modules.zsh.enable = true;
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.users.collin = {
              imports = [
                ./home
                ./users/collin/home.nix
                ./hosts/COPPER/home.nix
                plasma-manager.homeManagerModules.plasma-manager
                nix-index-database.hmModules.nix-index
              ];

              modules = {
                zsh.enable = true;
              };

              home.stateVersion = "23.05";
            };
          }
        ];
      };
    };

    packages.x86_64-linux = {
      ISO = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          ./config
          ./config/home.nix
          ./overlays
          ./modules
          {
            modules = {
              plasma.enable = true;
              ssh.enable = true;
              zsh.enable = true;
            };

            home-manager.users.nixos = {
              imports = [
                plasma-manager.homeManagerModules.plasma-manager
                nix-index-database.hmModules.nix-index
                ./home
              ];
              modules = {
                communication.enable = true;
                lock.enable = true;
                multimedia.enable = true;
                plasma.enable = true;
                utilities.enable = true;
                zsh.enable = true;
              };
              home.stateVersion = "23.05";
            };
          }
        ];
        format = "install-iso";
      };
    };

    # This doesn't work yet on the Pi4
    packages.aarch64-linux = {
      VIRIDIAN_IMAGE = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Global Config + Modules
          ./config
          ./config/linux.nix
          ./overlays
          ./modules
          ./hosts/VIRIDIAN/configuration.nix

          # Specialized Hardware Configuration
          ./hosts/VIRIDIAN/hardware-configuration.nix

          {
            modules = {
              ssh.enable = true;
              virtualisation.docker = true;
              zsh.enable = true;
            };
          }

          # User
          ./users
          ./users/collin
        ];
        format = "sd-aarch64";
      };
    };
  };
}
