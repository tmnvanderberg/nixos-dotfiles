{ config, pkgs, ... }:

let 
  my-python-packages = python-packages: with python-packages; [
    pyx
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # use VIM
  programs.vim.defaultEditor = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Probe windows
  boot.loader.grub.useOSProber = true;

  # hostname
  networking.hostName = "nixrp200";

  # localization
  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = ["all"];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  networking.networkmanager.enable = true;
  
  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # sound & bt
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;
  
  # set up user & groups
  users.users.tmn = {
    isNormalUser = true;
    home = "/home/tmn";
    description = "Timon van der Berg";
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "audio" 
      "video" 
      "input" 
      "tty"
    ];
    initialHashedPassword = "$6$TwDO8O6vF6gpV/OC$wOAFoqvpXV9WnbTvbqLRmQlGcb8oNMJeIMoyV1RtdLJztCZGZD3M0tNb6piyKSnoAz5UfVPwOAsjIB3SG8gE9/";
  };

  # enable unfree packages like propriatary drivers
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Use _configurable because it comes with python support
    vim_configurable
    wget
    ark
    tmux
    firefox
    git
    tdesktop
    kate
    vscode
    git-cola
    pavucontrol
    chromium
    openssh
    ranger
    discord
    aws
    texlive.combined.scheme-full
    spotify
    abiword
    jre8
    nodejs-17_x
    unzip
    qpaeq
    fzf
    silver-searcher
    nixfmt
    python
    python-with-my-packages
    signal-desktop
    ctags
    tigervnc
    docker
    clojure
    boot
    lua
    bat
  ];

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  # Initially installed version, don't change.
  system.stateVersion = "21.11"; 
}
