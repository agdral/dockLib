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
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin podcal --noclear %I $TERM"
    ];
  };

  home-manager.users.podcal = {
    services.podman.enable = true;
    programs = {
      bash.profileExtra = ''
        sleep 20
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
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
