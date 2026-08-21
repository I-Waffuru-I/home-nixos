
{ config, pkgs, ... }

{


}


 {
  environment.systemPackages = [
    pkgs.cloudflared
  ];
  services.cloudflared = {
   enable = true;
   tunnels = {
     "ec822526-d905-458b-932c-1b7fe6ba6fde" = {
       credentialsFile = "/opt/cloudflared/ec822526-d905-458b-932c-1b7fe6ba6fde.json";
       default = "http_status:404";
     };
   };

  };

 }
