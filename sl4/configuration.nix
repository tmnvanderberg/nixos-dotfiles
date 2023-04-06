{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      <nixos-hardware/microsoft/surface/surface-laptop-amd>
      ./hardware-configuration.nix
    ];
    
  # Add remote build machine
  nix.buildMachines = [{
    hostName = "builder";
    system = "x86_64-linux";
    maxJobs = 22;
    speedFactor = 10;
    supportedFeatures = [ "big-parallel" ];
    mandatoryFeatures = [ ];
  }];

  # build system on remote builders
  nix.distributedBuilds = true;

  # Download dependencies remotely
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelParams = [
    "acpi_backlight=vendor"
    "amd_iommu=off"
    "iommu=off"
  ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.utf8";
    LC_IDENTIFICATION = "nl_NL.utf8";
    LC_MEASUREMENT = "nl_NL.utf8";
    LC_MONETARY = "nl_NL.utf8";
    LC_NAME = "nl_NL.utf8";
    LC_NUMERIC = "nl_NL.utf8";
    LC_PAPER = "nl_NL.utf8";
    LC_TELEPHONE = "nl_NL.utf8";
    LC_TIME = "nl_NL.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account.
  users.users.tbe = {
    isNormalUser = true;
    description = "Timon van der Berg";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "tty" "network" "adbusers" ];
    packages = with pkgs; [
      firefox
      kate
      tdesktop
      yadm
      neovim
      exercism
      openvpn
      nerdfonts
      fzf
      tmux
      go
      cargo
      luajitPackages.luarocks
      php82Packages.composer
      julia
      rust-analyzer
      spotify
      vlc
      mplayer
      calibre
      lua
      ripgrep
      pavucontrol
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    gnumake
    cmake
    gcc
    python
    llvm
    nodejs
    xsel
    xclip
    tree
    pkg-config
    openssl
    clang
    unzip
    python3Full
    php
    jdk
    llvm
    clang-tools
  ];

  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp/nix-daemon";

  system.stateVersion = "22.05"; # do not touch

}
