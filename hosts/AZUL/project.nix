{ pkgs, inputs, ... }:
let
  # Override openocd with latest version from GitHub
  openocd = pkgs.openocd.overrideAttrs (oldAttrs: {
    version = "unstable-2025-01-15";

    src = pkgs.fetchFromGitHub {
      owner = "openocd-org";
      repo = "openocd";
      rev = "587c7831033cda2c5aa683d18a183df52b631004";
      hash = "sha256-nqu0fUI0M/SJtKovcLgBSDgiApE3JSemqOujyqcSz5I=";
    };

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.autoreconfHook ];
  });
in
{
  # Master's Project
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-uofl" ];
    externalInterface = "enp1s0";
  };

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", ATTRS{serial}=="M4321005", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="hsm", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef3", ATTRS{serial}=="M4321005", ENV{ID_USB_INTERFACE_NUM}=="03", SYMLINK+="debugger", MODE="0666"
  '';

  containers = {
    uofl = {
      autoStart = false;
      ephemeral = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";
      forwardPorts = [
        {
          containerPort = 4444;
          hostPort = 4444;
          protocol = "tcp";
        }
      ];
      additionalCapabilities = [
        "all" # Docker (Yes this compromises the security of the container completely)
      ];
      config = { pkgs, lib, config, ... }: {
        imports = [
          ../../modules/zsh.nix
          ../../modules/sanity.nix
          inputs.nix-index-database.nixosModules.nix-index
        ];
        
        modules = {
          zsh.enable = true;
          sanity.enable = true;
        };
        services.envfs.enable = lib.mkForce false; # This would cause systemd to throw "[!!!!!!] Refusing to run in unsupported environment where /usr/ is not populated."
        
        systemd.services.create-device-symlinks = {
          wantedBy = [ "multi-user.target" ];
          script = ''
            ln -sf /dev/hsm /dev/ttyACM0
            ln -sf /dev/debugger /dev/ttyACM1
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };

        services.code-server = {
          enable = true;
          user = "ectf";
          host = "0.0.0.0";
          disableTelemetry = true;
          disableUpdateCheck = true;
          hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$MnFscWo4dHh1d094YjRoS08yd01nY0NHamxNPQ$cTROL0UHOveImUtpYvt6hflLni43xeKaH8kDGbB/JW4";
          extraEnvironment = {
            EXTENSIONS_GALLERY = ''{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl":"https://marketplace.visualstudio.com/items","controlUrl":"","recommendationsUrl":""}'';
          };
        };
        #nix-shell -p autoPatchelfHook systemd stdenv.cc.cc --run  'autoPatchelf /home/collin/ectf/.local/share/code-server/extensions/ms-vscode.vscode-serial-monitor-0.13.1/dist/node_modules/usb/prebuilds/linux-x64/node.napi.glibc.node'

        users.groups.ectf.gid = 1000;
        users.users.ectf = {
          group = "ectf";
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "dialout" "docker" ];
        };

        programs.zsh.shellAliases.ectf = "uvx ectf";

        virtualisation.docker.enable = true;

        programs.nix-index-database.comma.enable = true;
        programs.command-not-found.enable = false;

        nix = {
          settings = {
            experimental-features = "nix-command flakes";
            trusted-users = [ "@wheel" ];
          };
          registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
          nixPath = (lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry) ++ [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
        };

        environment.systemPackages = with pkgs; [
          zoxide
          htop
          fastfetch
          git
          nano
          wget
          curl
          aria2
          eza

          gnumake
          uv
          openocd
          inputs.pwndbg.packages.x86_64-linux.default
        ];

        users.defaultUserShell = pkgs.zsh;
        
        networking.firewall.enable = false;
        system.stateVersion = "25.05";
      };
      allowedDevices = [
        {
          node = "/dev/hsm";
          modifier = "rwm";
        }
        {
          node = "/dev/debugger";
          modifier = "rwm";
        }
      ];
      bindMounts = {
        "/home/ectf" = {
          hostPath = "/home/collin/ectf";
          isReadOnly = false;
        };
        "/dev/hsm" = {
          hostPath = "/dev/hsm";
          isReadOnly = false;
        };
        "/dev/debugger" = {
          hostPath = "/dev/debugger";
          isReadOnly = false;
        };
      };
    };
  };
}
