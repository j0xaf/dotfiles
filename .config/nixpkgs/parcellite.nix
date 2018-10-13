{ pkgs, lib ? pkgs.stdenv.lib, ... }:
{
  services.parcellite.enable = true;
  xdg = {
    configFile."parcellite/parcelliterc".source = ./files/.config/parcellite/parcelliterc;
  };
}
