{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "tmn";
  home.homeDirectory = "/home/tmn";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # user packages
  home.packages = with {
    p = pkgs;
  }; [
	p.tdesktop
	p.git
	p.vscode
	p.nodejs
	p.nodePackages.npm
	p.git-crypt
	p.gnupg
	p.chromium
  ];
}
