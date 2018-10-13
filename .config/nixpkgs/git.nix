{ pkgs, config, lib ? pkgs.stdenv.lib, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {};
in {
  home = {
    packages = with pkgs; [
      git-lfs
      gitAndTools.ghq
      unstable.gitAndTools.pass-git-helper
    ];
  };

  programs.git = {
    enable = true;
    userName = "Jörn Gersdorf";
    userEmail = "joern.gersdorf@dwpbank.de";
    ignores = [
      "*~"
      ".DS_Store" ];
    extraConfig = {
      credential.helper = "${unstable.gitAndTools.pass-git-helper}/bin/pass-git-helper";
#      credential.helper = "cache";
      "filter \"lfs\"" = {
          clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
          smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
          required = true;
      };
      ghq = {
        root = "${config.home.homeDirectory}/git";
      };
    };
  };

  xdg = {
    configFile."pass-git-helper/git-pass-mapping.ini".text = ''
      '';
  };
}
