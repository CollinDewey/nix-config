{ config, lib, pkgs, inputs, ... }:

{
  # Imports
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ];

  # Boot
  boot = {
    # Kernel
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" ]; # Early KMS
      systemd.enable = true;  
      systemd.services.initrd-brightness = {
        unitConfig.DefaultDependencies = false;
        wantedBy = [ "initrd.target" ];
        requires = [
          ''sys-devices-pci0000:00-0000:00:02.0-drm-card1-card1\x2deDP\x2d1-intel_backlight.device''
          ''sys-devices-pci0000:00-0000:00:02.0-drm-card1-card1\x2deDP\x2d2-card1\x2deDP\x2d2\x2dbacklight.device''
        ];
        before = [ "plymouth-start.service" ];
        after = [
          ''sys-devices-pci0000:00-0000:00:02.0-drm-card1-card1\x2deDP\x2d1-intel_backlight.device''
          ''sys-devices-pci0000:00-0000:00:02.0-drm-card1-card1\x2deDP\x2d2-card1\x2deDP\x2d2\x2dbacklight.device''
        ];
        script = ''
          echo 200 > '/sys/devices/pci0000:00/0000:00:02.0/drm/card1/card1-eDP-1/intel_backlight/brightness'
          echo  0 > '/sys/devices/pci0000:00/0000:00:02.0/drm/card1/card1-eDP-2/card1-eDP-2-backlight/brightness'
        '';
      };  
    };
    extraModulePackages = with config.boot.kernelPackages; [ (kvmfr.overrideAttrs (_: { patches = ( pkgs.fetchpatch { url = "https://github.com/gnif/LookingGlass/commit/7305ce36af211220419eeab302ff28793d515df2.patch"; hash = "sha256-97nZsIH+jKCvSIPf1XPf3i8Wbr24almFZzMOhjhLOYk="; stripLen = 1; }); })) v4l2loopback ];
    kernelModules = [ "kvm-amd" "uinput" "kvmfr" ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    kernelParams = [ "mitigations=off" "retbleed=off" ];
    kernelPackages = pkgs.linuxPackages_testing;
    kernel.sysctl = { "kernel.sysrq" = 1; };

    # Filesystems
    supportedFilesystems = [ "ntfs" ];

    # Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    sensor.iio.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        vpl-gpu-rt
      ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;
  services.hardware.bolt.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
  systemd.tmpfiles.rules = [
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80" # 80% Battery Limit Default
  ];

  # Second Screen Disable + KVMFR rule
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", ENV{WAYLAND_DISPLAY}="/run/user/1000/wayland-0", RUN+="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-2.disable"
    ACTION=="remove", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", ENV{WAYLAND_DISPLAY}="/run/user/1000/wayland-0", RUN+="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-2.enable output.eDP-2.position.0,900"
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
  '';

  # Networking
  time.timeZone = "America/Louisville";
  #time.hardwareClockInLocalTime = true; # Windows is silly and I need it for work/school
  networking = {
    hostName = "BURGUNDY";
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      # Syncthing
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
      checkReversePath = false; # Wireguard
    };
  };

  # Video
  environment.variables.__RM_NO_VERSION_CHECK = "1";

  # VFIO
  environment.etc."looking-glass-client.ini".text = ''
    [app]
    shmFile=/dev/kvmfr0
  '';
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    namespaces = []
    cgroup_device_acl = [
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kvmfr0"
    ]
  '';
  #systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 collin kvm -" ];
  virtualisation.spiceUSBRedirection.enable = true;

  # Disks
  boot.tmp.cleanOnBoot = true;

  # BTRFS Scrubbing
  services.btrfs.autoScrub = {
    fileSystems = [ "/home" ]; # Crosses subpartition bounds
    enable = true;
    interval = "weekly";
  };

  # BTRFS De-duplicating
  services.beesd.filesystems = {
    system = {
      spec = "/home";
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
    };
  };

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      enableWarnings = false;
      directories = [
        "/var/log" # Keep system logs
        "/var/lib/docker" # Keep Docker junk
        "/var/lib/libvirt" # Keep KVM junk
        "/var/lib/iwd" # I like using WiFi
        "/var/lib/bluetooth" # I like using my keyboard
        { directory = "/var/lib/syncthing"; user = "collin"; group = "collin"; }
        "/var/lib/NetworkManager" # I like using WiFi
        "/etc/NetworkManager/system-connections" # I like using WiFi
      ];
      files = [
        "/etc/machine-id" # Honestly no idea why we need this to be the same between boots
        "/etc/ssh/ssh_host_ed25519_key" # Not reset my host keys
        "/etc/ssh/ssh_host_ed25519_key.pub" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key" # Not reset my host keys
        "/etc/ssh/ssh_host_rsa_key.pub" # Not reset my host keys
      ];
   };
  };

  # Sops Key File Location
  sops.age.keyFile = "/persist/sops-key.txt";
}