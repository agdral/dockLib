{pkgs, ...}: {
  home-manager.users.podcal = {
    home = {
      stateVersion = "26.11";

      sessionVariables = {
        UMASK = "007";
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    programs = {
      bash = {
        enable = true;
        initExtra = "umask 0007";
        profileExtra = ''
          dbus-update-activation-environment --systemd --all
          systemctl --user start podman-init.target
        '';
      };
      fish = {
        enable = true;
        shellInit = "umask 0007";
      };
    };

    services.podman = {
      enable = true;
      networks = {
        proxy_network = {
          driver = "bridge";
          subnet = "10.100.0.0/24";
          gateway = "10.100.0.1";
          extraPodmanArgs = ["--dns-enable=true"];
        };
      };
    };

    systemd.user = {
      targets.podman-init = {
        Unit = {
          Description = "Podman initialization";
          After = ["default.target"];
        };
      };

      sessionVariables = {
        XDG_RUNTIME_DIR = "/run/user/1010";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1010/bus";
      };
    };

    home.packages = with pkgs; [
      podman
      podman-compose
    ];
  };
}
