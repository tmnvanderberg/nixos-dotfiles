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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # nvidia gpu drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    ark
    tmux
    firefox
    git
    tdesktop
    kate
    fzf
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
    partition-manager
    mumble
    unstable.neovim
    glibc
    glibcLocales
    gcc
    libcxx
    llvm
    xclip
    ripgrep
    steam
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
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
