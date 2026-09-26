{ config, pkgs, ... }:

{
  sops.secrets."gh_waffsite_read" = {
    owner = "sitedeploy";
    group = "gitdeploy"; # staat in configuration.nix
    mode = "0400";
  };

  users.groups.blogwriter = {};

  users.users.sitedeploy = {
    isSystemUser = true;
    group = "gitdeploy";
    extraGroups = [ "keys" "blogwriter" ]; # keys laat toe dat die secrets leest
    createHome = true;
    home = "/var/www/sitedeploy/";
  };

  users.users.matha.extraGroups = [ "blogwriter" ];


  systemd.services.pull-waffsite = {
    description = "Make script to pull/clone repo and build it from source";
    path = [ pkgs.git pkgs.openssh pkgs.cargo pkgs.rustc pkgs.gcc];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "sitedeploy";
      Group = "gitdeploy";
      ExecStart = pkgs.writeShellScript "pull-waffsite" ''
        set -e
        export GIT_SSH_COMMAND="ssh -i ${config.sops.secrets."gh_waffsite_read".path} -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/www/sitedeploy/known_hosts"

        REPO_DIR=/var/www/web/waffsite
        if [ -d "$REPO_DIR/.git" ]; then
          git -C "$REPO_DIR" pull
        else
          git clone git@github.com:I-Waffuru-I/waffsite.git "$REPO_DIR"
        fi

        cd "$REPO_DIR/blogger"
        cargo build --release
        '';
    };
  };


  systemd.timers.pull-waffsite = {
    description = "Periodically pull waffsite";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "0";
      OnUnitActiveSec = "12h";
    };
  };

  systemd.services.deploy-waffsite = {
    description = "Run/deploy the rocket app";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "pull-waffsite.service" ];

    serviceConfig = {
      ExecStart = ''
        /var/www/web/waffsite/blogger/target/release/blogger \
            /var/www/web/waffsite/site \
            /var/www/web/blogs
      '';

      Type = "simple";
      Restart = "on-failure";
      RestartSec = "60s";

      User = "sitedeploy";
      Group = "gitdeploy";

      Environment = [
        "ROCKET_ADDRESS=127.0.0.1"
        "ROCKET_PORT=8000"
      ];

    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/web/waffsite 0750 sitedeploy gitdeploy -"
    "d /var/www/web/blogs 2770 sitedeploy writer -"
  ];

}
