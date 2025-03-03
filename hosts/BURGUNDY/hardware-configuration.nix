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
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    extraModulePackages = with config.boot.kernelPackages; [ kvmfr v4l2loopback ];
    kernelModules = [ "kvm-amd" "uinput" "kvmfr" ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    kernelParams = [ "mitigations=off" "retbleed=off" "initcall_blacklist=sysfb_init" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernel.sysctl = {
      "kernel.sysrq" = 1; # Allow all sysrq
      "kernel.nmi_watchdog" = 0; # Power Saving
      "vm.dirty_writeback_centisecs" = 1500; # Power Saving
    };

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
    graphics = {
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
  services.hardware.bolt.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Power Settings
  services.thermald.enable = true;
  systemd.tmpfiles.rules = [
    "w /sys/module/snd_hda_intel/parameters/power_save - - - - 1" # snd_hda_intel Power Save
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80" # 80% Battery Limit Default
  ];

  # Second Screen Disable + KVMFR rule
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", RUN+="${pkgs.systemd}/bin/systemctl --no-block start zenbook-keyboard.service"
    ACTION=="remove", SUBSYSTEM=="input", ATTRS{name}=="Primax Electronics Ltd. ASUS Zenbook Duo Keyboard Touchpad", ATTRS{id/vendor}=="0b05", ATTRS{id/product}=="1b2c", RUN+="${pkgs.systemd}/bin/systemctl --no-block start zenbook-keyboard.service"
    SUBSYSTEM=="kvmfr", OWNER="root", GROUP="libvirtd", MODE="0660"
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
  '';
  #  SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start beesd@system.service"
  #  SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block stop beesd@system.service"
  systemd.services.zenbook-keyboard = {
    description = "Sync displays with keyboard connect state";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 0.1"; # On disconnect, the script sometimes gets called before the device is removed
      ExecStart = "${pkgs.bash}/bin/bash /etc/zenbook/zenbook-keyboard.sh";
      TimeoutStartSec = "1s";
    };
    unitConfig = {
      StartLimitIntervalSec = 0.2;
      StartLimitBurst = 1;
    };
  };
  systemd.services.display-manager-startup = {
    description = "Sync display-manager with keyboard connect state";
    wantedBy = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1"; # Can probably be lower, but a second doesn't matter to me
      ExecStart = "${pkgs.bash}/bin/bash /etc/zenbook/zenbook-keyboard.sh";
      TimeoutStartSec = "2s";
    };
  };
  environment.etc."zenbook/zenbook-keyboard.sh" = {
    mode = "0555";
    text = ''
      #${pkgs.bash}/bin/bash
      export WAYLAND_DISPLAY=$(find /run/user/*/wayland-0)

      if [ -n "$WAYLAND_DISPLAY" ]; then
        if ${pkgs.usbutils}/bin/lsusb | grep -q "0b05:1b2c"; then
            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.enable output.eDP-2.disable
        else
            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-1.enable output.eDP-1.position.0,0 output.eDP-2.enable output.eDP-2.position.0,900
        fi
      fi
    '';
  };

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
  #services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia.open = false;

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
  # Bees is more of an IO hastle than it's worth
  #services.beesd.filesystems = {
  #  system = {
  #    spec = "/home";
  #    hashTableSizeMB = 1024;
  #    verbosity = "crit";
  #    extraOptions = [ "--thread-count" "2" "--loadavg-target" "5.0" ];
  #  };
  #};
  #systemd.services."beesd@system".unitConfig.ConditionACPower = "true";

  # Persistance
  users.mutableUsers = false;
  systemd.coredump.extraConfig = "Storage=none";
  fileSystems."/persist".neededForBoot = true;
  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName; # The machine-id is supposed to be secret, but we don't care. 
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
