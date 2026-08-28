{ config, pkgs, ... }: 
let
  sops-nix = builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
in {

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
  ];

  imports = [ "${sops-nix}/modules/sops" ];

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/opt/age/keys.txt";

  };

}



