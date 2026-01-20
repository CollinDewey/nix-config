{
  description = "Collin's Nix Configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11-small";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    copyparty.url = "github:9001/copyparty";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.home-manager.follows = "home-manager-stable";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvirt = {
      url = "github:AshleyYakeley/NixVirt/0785bd6350e81ffd009c87d6fcedc35018ac5444";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nvidia-vgpu = {
      url = "github:CollinDewey/nixos-nvidia-vgpu";
      #      url = "git+file:/services/syncthing/Desktop/Git/CollinDewey/nixos-nvidia-vgpu";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-unstable-small, nixpkgs-stable, impermanence, nixos-hardware, chaotic, flake-utils, copyparty, sops-nix, nix-index-database, darwin, disko, home-manager-unstable, home-manager-stable, plasma-manager, nixos-generators, deploy-rs, nixvirt, nvidia-vgpu, system-manager, nix-system-graphics, nixpkgs-xr, pwndbg, ... }@inputs:
    let
      pkgs = import nixpkgs-stable { system = "x86_64-linux"; };
      deployPkgs = import nixpkgs-stable {
        system = "x86_64-linux";
        overlays = [
          deploy-rs.overlays.default
          (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };

      pkgsARM = import nixpkgs-stable { system = "aarch64-linux"; };
      deployPkgsARM = import nixpkgs-stable {
        system = "aarch64-linux";
        overlays = [
          deploy-rs.overlays.default
          (self: super: { deploy-rs = { inherit (pkgsARM) deploy-rs; lib = super.deploy-rs.lib; }; })
        ];
      };
    in
    {
      nixosConfigurations = {
        CYAN = nixpkgs-unstable-small.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Global Config + Modules
            ./config
            ./config/linux.nix
            ./overlays
            ./modules
            ./hosts/CYAN/configuration.nix

            # Specialized Hardware Configuration
            ./hosts/CYAN/hardware-configuration.nix

            {
              modules = {
                plasma.enable = true;
                printing.enable = true;
                sanity.enable = true;
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
            ./users/shimmer
            chaotic.nixosModules.default
            nixpkgs-xr.nixosModules.nixpkgs-xr
            home-manager-unstable.nixosModules.home-manager
            ./config/home.nix

            {

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {

                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/CYAN/home.nix

                  # User Specific Config
                  ./users/collin/home.nix
                ];

                modules = {
                  communication.enable = true;
                  cyber.enable = true;
                  gaming.enable = true;
                  klipper.enable = true;
                  lock.enable = true;
                  misc.enable = true;
                  multimedia.enable = true;
                  office.enable = false;
                  plasma.enable = true;
                  #plover.enable = true; # Plover 4.0.0.dev10 broke for no reason????
                  utilities.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "23.11";
              };

              home-manager.users.shimmer = {
                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/CYAN/home.nix

                  # User Specific Config
                  ./users/shimmer/home.nix
                ];

                modules = {
                  communication.enable = true;
                  gaming.enable = true;
                  lock.enable = true;
                  misc.enable = true;
                  multimedia.enable = true;
                  plasma.enable = true;
                  utilities.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "23.11";
              };
            }
          ];
        };

        BURGUNDY = nixpkgs-unstable-small.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Global Config + Modules
            ./config
            ./config/linux.nix
            ./overlays
            ./modules
            ./hosts/BURGUNDY/configuration.nix
            ./hosts/BURGUNDY/disko.nix
            ./hosts/BURGUNDY/hardware-configuration.nix

            {
              modules = {
                plasma.enable = true;
                printing.enable = true;
                sanity.enable = true;
                ssh.enable = true;
                virtualisation = {
                  docker = true;
                  libvirt = true;
                  nvidia = false;
                };
                zsh.enable = true;
              };
            }

            # User
            ./users
            ./users/collin
            ./users/shimmer
            chaotic.nixosModules.default
            nixpkgs-xr.nixosModules.nixpkgs-xr
            home-manager-unstable.nixosModules.home-manager
            ./config/home.nix

            {

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {

                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/BURGUNDY/home.nix

                  # User Specific Config
                  ./users/collin/home.nix
                ];

                modules = {
                  communication.enable = true;
                  cyber.enable = true;
                  gaming.enable = true;
                  klipper.enable = true;
                  lock.enable = true;
                  misc.enable = true;
                  multimedia.enable = true;
                  office.enable = false;
                  plasma.enable = true;
                  #plover.enable = true;
                  utilities.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "24.11";
              };

              home-manager.users.shimmer = {
                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/BURGUNDY/home.nix

                  # User Specific Config
                  ./users/shimmer/home.nix
                ];

                modules = {
                  communication.enable = true;
                  gaming.enable = true;
                  lock.enable = true;
                  misc.enable = true;
                  multimedia.enable = true;
                  plasma.enable = true;
                  utilities.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "24.11";
              };
            }
          ];
        };

        VM = nixpkgs-unstable-small.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Global Config + Modules
            ./config
            ./config/linux.nix
            ./overlays
            ./modules
            ./hosts/VM/configuration.nix

            # Specialized Hardware Configuration
            ./hosts/VM/hardware-configuration.nix

            {
              modules = {
                plasma.enable = true;
                printing.enable = true;
                sanity.enable = true;
                ssh.enable = true;
                virtualisation = {
                  docker = true;
                  libvirt = true;
                };
                zsh.enable = true;
              };
            }

            # User
            #./users # This includes the root passwd through sops, which we wont have here.
            ./users/dummy
            chaotic.nixosModules.default
            home-manager-unstable.nixosModules.home-manager
            ./config/home.nix

            {

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.dummy = {

                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # User Specific Config
                  ./users/dummy/home.nix
                ];

                modules = {
                  communication.enable = true;
                  cyber.enable = true;
                  gaming.enable = true;
                  klipper.enable = true;
                  lock.enable = true;
                  misc.enable = true;
                  multimedia.enable = true;
                  #office.enable = true;
                  plasma.enable = true;
                  #plover.enable = true;
                  utilities.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "24.05";
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
            ./hosts/TEAL/disko.nix
            ./hosts/TEAL/external-disks.nix
            ./hosts/TEAL/containers

            # Specialized Hardware Configuration
            ./hosts/TEAL/hardware-configuration.nix

            copyparty.nixosModules.default
            {
              nixpkgs.overlays = [ copyparty.overlays.default ];
              modules = {
                printing.enable = true;
                ssh.enable = true;
                virtualisation = {
                  docker = true;
                  libvirt = true;
                  nvidia = true;
                  ipv6 = true;
                };
                zsh.enable = true;
                server.enable = true;
              };
            }

            # User
            ./users
            ./users/collin
            home-manager-stable.nixosModules.home-manager
            ./config/home.nix

            {

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {

                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/TEAL/home.nix

                  # User Specific Config
                  ./users/collin/home.nix
                ];

                modules = {
                  zsh.enable = true;
                };

                home.stateVersion = "22.11";
              };
            }
          ];
        };

        AZUL = nixpkgs-unstable-small.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Global Config + Modules
            ./config
            ./config/linux.nix
            ./overlays
            ./modules
            ./hosts/AZUL/configuration.nix
            ./hosts/AZUL/project.nix

            # Specialized Hardware Configuration
            ./hosts/AZUL/hardware-configuration.nix

            {
              modules = {
                plasma.enable = true;
                ssh.enable = true;
                zsh.enable = true;
              };
            }

            # User
            ./users
            ./users/collin
            chaotic.nixosModules.default
            home-manager-unstable.nixosModules.home-manager
            ./config/home.nix

            {

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {

                imports = [
                  # Modules
                  plasma-manager.homeModules.plasma-manager
                  ./home

                  # Computer Specific Config
                  ./hosts/AZUL/home.nix

                  # User Specific Config
                  ./users/collin/home.nix
                ];

                modules = {
                  klipper.enable = true;
                  lock.enable = true;
                  multimedia.enable = true;
                  plasma.enable = true;
                  zsh.enable = true;
                };

                home.stateVersion = "24.05";
              };
            }
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
            ./hosts/BROWN/configuration.nix

            # Specialized Hardware Configuration
            ./hosts/BROWN/hardware-configuration.nix

            {
              modules = {
                ssh.enable = true;
                virtualisation.docker = true;
                zsh.enable = true;
                server.enable = true;
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
                server.enable = true;
              };
            }

            # User
            ./users
            ./users/collin
          ];
        };

        RUBY = nixpkgs-stable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Global Config + Modules
            ./config
            ./config/linux.nix
            ./overlays
            ./modules

            # Specialized Hardware Configuration
            ./hosts/RUBY/hardware-configuration.nix

            {
              modules = {
                ssh.enable = true;
                virtualisation.docker = true;
                zsh.enable = true;
                server.enable = true;
              };
            }

            # User
            ./users
            ./users/collin
          ];
        };
      };

      systemConfigs = {
        CYBERL = system-manager.lib.makeSystemConfig {
          extraSpecialArgs.pkgs = import nixpkgs-unstable {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
            };
          };
          modules = [
            nix-system-graphics.systemModules.default
            ./hosts/CYBERL/system.nix
          ];
        };
      };

      homeConfigurations.CYBERL = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-unstable { system = "x86_64-linux"; };
        extraSpecialArgs = { inherit inputs; };

        modules = [
          ./home
          ./users/collin/home.nix
          ./hosts/CYBERL/home.nix
          plasma-manager.homeModules.plasma-manager
          nix-index-database.homeModules.nix-index
          {
            modules = {
              plasma.enable = true;
              plasma.packages = false;
              zsh.enable = true;
            };
            home.stateVersion = "24.05";
          }
        ];
      };

      darwinConfigurations = {
        MAUVE = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./config
            ./config/home.nix
            ./hosts/MAUVE/configuration.nix
            ./modules/zsh.nix
            {
              modules.zsh.enable = true;
            }
            home-manager-unstable.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {
                imports = [
                  ./home
                  ./users/collin/home.nix
                  plasma-manager.homeModules.plasma-manager
                  nix-index-database.homeModules.nix-index
                ];

                modules = {
                  zsh.enable = true;
                };

                home.stateVersion = "22.11";
              };
            }
          ];
        };
        JADE = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./config
            ./config/home.nix
            ./hosts/JADE/configuration.nix
            ./modules/zsh.nix
            {
              modules.zsh.enable = true;
            }
            home-manager-unstable.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.collin = {
                imports = [
                  ./home
                  ./users/collin/home.nix
                  plasma-manager.homeModules.plasma-manager
                  nix-index-database.homeModules.nix-index
                ];

                modules = {
                  zsh.enable = true;
                };

                home.stateVersion = "22.11";
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
            home-manager-stable.nixosModules.home-manager
            ./config
            ./config/home.nix
            ./hosts/ISO/configuration.nix
            ./overlays
            ./modules
            {
              modules = {
                plasma.enable = true;
                ssh.enable = true;
                zsh.enable = true;
              };

              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.nixos = {
                imports = [
                  plasma-manager.homeModules.plasma-manager
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
                home.stateVersion = "23.11";
              };
              system.stateVersion = "23.11";
            }
          ];
          format = "install-iso";
        };
      };

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

      deploy = {
        user = "root";
        interactiveSudo = true;
        fastConnection = true;
        remoteBuild = true;

        nodes = {
          CYAN = {
            hostname = "CYAN.TERASCRIPTING";
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.CYAN;
          };

          BURGUNDY = {
            hostname = "BURGUNDY.TERASCRIPTING";
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.BURGUNDY;
          };

          TEAL = {
            hostname = "TEAL.TERASCRIPTING";
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.TEAL;
          };

          AZUL = {
            hostname = "AZUL.TERASCRIPTING";
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.AZUL;
            remoteBuild = false;
          };

          MAUVE = {
            hostname = "MAUVE.TERASCRIPTING";
            profiles.system.path = deploy-rs.lib.x86_64-darwin.activate.darwin self.darwinConfigurations.MAUVE;
          };

          BROWN = {
            hostname = "BROWN.TERASCRIPTING.COM";
            profiles.system.path = deployPkgsARM.deploy-rs.lib.activate.nixos self.nixosConfigurations.BROWN;
          };

          SCARLET = {
            hostname = "SCARLET.TERASCRIPTING.COM";
            profiles.system.path = deployPkgsARM.deploy-rs.lib.activate.nixos self.nixosConfigurations.SCARLET;
          };

          RUBY = {
            hostname = "RUBY.TERASCRIPTING.COM";
            profiles.system.path = deployPkgsARM.deploy-rs.lib.activate.nixos self.nixosConfigurations.RUBY;
          };
        };
      };
      # Check is too demanding
      #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
