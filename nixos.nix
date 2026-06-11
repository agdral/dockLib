{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [pkgs.shadow];
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [pkgs.bash]}"
  '';

  systemd.services."getty@tty4" = {
    overrideStrategy = "asDropin";
    wantedBy = ["getty.target"];
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin podcal --noclear %I $TERM"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 0;
  };

  users.groups.podman = {
    name = "podman";
  };

  users.users.podcal = {
    isNormalUser = true;
    home = "/home/podcal";
    uid = 1010;
    description = "podcal user";
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
    extraGroups = [
      "networkmanager"
      "dialout"
      "audio"
      "podman"
    ];
  };
}
