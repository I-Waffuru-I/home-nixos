
{ config, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.cloudflared
  ];

  services.cloudflared = {
   enable = true;
   tunnels = {
     "ec822526-d905-458b-932c-1b7fe6ba6fde" = {
       credentialsFile = config.sops.secrets."cloudflared-tunnel-json".path;
       ingress = {
         "ssh.waffuru.net" = "ssh://localhost:2222";
       };
       default = "http_status:404";
     };
   };
  };

 }
