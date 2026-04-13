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

  users.groups.podman = {
    name = "podman";
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

  home-manager.users.podcal = {
    xdg.configFile."containers/networks/proxy_network.json" = {
      text = builtins.toJSON {
        name = "proxy_network";
        driver = "bridge";
        network_interface = "proxy_network";
        subnets = [
          {
            subnet = "10.100.0.0/24";
            gateway = "10.100.0.1";
          }
        ];
        ipv6_enabled = false;
        internal = false;
        dns_enabled = true;
        ipam_options = {driver = "host-local";};
      };
    };
    services.podman = {
      enable = true;
    };
    systemd.user.sessionVariables = {
      XDG_RUNTIME_DIR = "/run/user/1010";
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1010/bus";
    };
    programs = {
      bash.profileExtra = ''
        dbus-update-activation-environment --systemd --all
        systemctl --user start podman-init.target
      '';
    };

    home.packages = with pkgs; [
      podman
      podman-compose
    ];

    systemd.user.targets.podman-init = {
      Unit = {
        Description = "Podman initialization";
        After = ["default.target"];
      };
    };
  };
}
