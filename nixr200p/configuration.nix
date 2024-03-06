{ config, pkgs, ... }:

let 
  my-python-packages = python-packages: with python-packages; [
    pyx
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
  unstable = import <unstable> {};
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

  # use amd driver for GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # permit required insure package
  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.7"
  ];
    	
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

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

  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      # ${tailscale}/bin/tailscale up -authkey  '';
  };

  # Select internationalisation properties.
  i18n.supportedLocales = [ "all" "en_US.UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

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

  nixpkgs.config = {
    packageOverrides = super: {
      mplayer = super.mplayer.override {
        v4lSupport = true;
      };
    };
  };

  # bluetooth
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;

  # pipewire sound server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # docker
  virtualisation.docker.enable = true;

  # steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  
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
      "docker"
      "dialout"
    ];
  };

  nix.settings.trusted-users = [ "root" "tmn"];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';


  # enable unfree packages like propriatary drivers
  nixpkgs.config.allowUnfree = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  environment.systemPackages = with pkgs; 
  let 
    rstudio-pri = rstudioWrapper.override {
      packages = with rPackages;
        [
          ggplot2
          dplyr
          xts
          curl
          png
          jpeg
          xml2
          cairo
          zlib
          haven
          tidyverse
          lme4
          extraDistr
          brms
          ggtext
          patchwork
          bayesplot
          magrittr
          tailscale
        ];
    };
  in 
  [
    yadm
    wget
    ark
    tmux
    firefox
    git
    git-annex
    tdesktop
    pavucontrol
    chromium
    openssh
    ranger
    texlive.combined.scheme-full
    spotify
    jre8
    nodejs-18_x
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
    partition-manager
    unstable.neovim
    glibc
    glibcLocales
    gcc
    libcxx
    llvm
    xclip
    xsel
    ripgrep
    nerdfonts
    libsForQt5.kteatime
    openvpn
    unstable.openra
    unstable.mono
    unstable.msbuild
    gnumake
    tmux
    mplayer
    clang
    clang-tools
    comma
    calibre
    go
    cargo
    luajitPackages.luarocks
    jdk 
    php
    opam
    google-chrome
    quarto
    kate
    cmake
    openssl.dev
    nodePackages.typescript-language-server
    tailscale
    wireguard-go
  ];

  services.openssh = {
    enable = true;
  };
  services.openssh.settings = {
    PasswordAuthentication = true;
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    extraConfig = ''
# copy to system clipboard
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xsel -i -b --clipboard'

# Explicit default
set -g @paste_eselection 'clipboard'

# vi mode
setw -g mode-keys vi

# Set new panes to open in current directory
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# lower escape times to prevent delayonfiguration
set -sg escape-time 10

# enable mouse 
set -g mouse on

# start session number from 1 rather than 0
set -g base-index 0

# start pane number from 1 similar to windows
set -g pane-base-index 0

# theme
set -g @tmux-gruvbox 'dark' # or 'light'

# save nvim sessions
set -g @resurrect-strategy-nvim 'session'

# save panes
set -g @resurrect-capture-pane-contents 'on'

# increase history limit 
set -g history-limit 50000

# config tmux-logging plugin
set -g @logging-path "$HOME/Documents/logs/"
set -g @screencapture-path "$HOME/Documents/logs/"
set -g @save-complete-history-path "$HOME/Documents/logs/dump/"

# source .tmux.conf file
bind r source-file /etc/.conf \; display "Configuration Reloaded!"

# tmux plugins using plugin manager (loaded below)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-open'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'tmux-plugins/tmux-fpp'
set -g @plugin 'brennanfee/tmux-paste'
set -g @plugin 'tmux-plugins/tmux-logging'
set -g @plugin 'lljbash/tmux-update-display'
set -g @plugin 'egel/tmux-gruvbox'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
    '';
  };

  programs.ssh.startAgent = true;

  # Initially installed version, don't change.
  system.stateVersion = "21.11"; 
}
