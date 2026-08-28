
{ config, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.cloudflared
  ];

    sops.secrets."cloudflared-tunnel-json" = {
      owner = "root";
      mode = "0400";
    };

  services.cloudflared = {
   enable = true;
   tunnels = {
     "ec822526-d905-458b-932c-1b7fe6ba6fde" = {
       credentialsFile = config.sops.secrets."cloudflared-tunnel-json".path;
       ingress = {
          "ssh.waffuru.net" = "ssh://localhost:2222";
          "www.waffuru.net" = "http://localhost:80";
       };
       default = "http_status:404";
     };
   };
  };

 }
