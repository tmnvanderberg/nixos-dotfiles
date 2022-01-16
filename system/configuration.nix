{ config, pkgs, ... }:

{
  imports =
    [ 
	    ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Probe windows
  boot.loader.grub.useOSProber = true;

  # hostname
  networking.hostName = "nixrp200";

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # blue
  hardware.bluetooth.enable = true;

  # Define a user account.
  users.users.tmn = {
    isNormalUser = true;
    home = "/home/tmn";
    description = "Timon van der Berg";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed 
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    git
    tdesktop
    kate
    vscode
    nodejs
    git-cola
    pavucontrol
    chromium
    openssh
    ranger
    discord
    nodePackages.npm
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # start ssh key agent
  programs.ssh.startAgent = true;

  # Initially installed version, don't change.
  system.stateVersion = "21.11"; 
}

