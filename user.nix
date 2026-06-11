{...}: {
  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 0;
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

  home-manager.users.podcal = {
    home = {
      stateVersion = "26.05";

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
      };
      fish = {
        enable = true;
        shellInit = "umask 0007";
      };
    };
  };
}
