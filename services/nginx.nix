{ config, pkgs, ... }:

{
  sops.secrets."gh_waffsite_read" = {
    owner = "sitedeploy";
    group = "gitdeploy"; # staat in configuration.nix
    mode = "0400";
  };

  users.users.sitedeploy = {
    isSystemUser = true;
    group = "gitdeploy";
    extraGroups = [ "keys" ]; # laat toe dat die secrets leest
    createHome = true;
    home = "/var/www/sitedeploy/";
  };

  systemd.services.deploy-waffsite = {
    description = "Make script to pull/clone repo";
    path = [ pkgs.git pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "sitedeploy";
      Group = "gitdeploy";
      ExecStart = pkgs.writeShellScript "deploy-waffsite" ''
        set -e
        export GIT_SSH_COMMAND="ssh -i ${config.sops.secrets."gh_waffsite_read".path} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/www/sitedeploy/known_hosts"
        if [ -d /var/www/web/waffsite/.git ]; then
          git -C /var/www/web/waffsite pull
        else
          git clone git@github.com:I-Waffuru-I/waffsite.git /var/www/web/waffsite
        fi
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/web/waffsite 0755 sitedeploy gitdeploy -"
  ];

  systemd.timers.deploy-waffsite = {
    description = "Periodically pull waffsite";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "2h";
    };
  };

}
