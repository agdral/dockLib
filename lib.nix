{
  pkgs,
  lib,
}: {
  mkPodmanService = {
    name,
    composeFile,
    user,
    enable ? true,
  }: {
    home-manager.users.${user}.systemd.user.services.${name} =
      {
        Unit.PartOf = ["podman-init.target"];
        Service = {
          ExecStart = "${pkgs.podman}/bin/podman compose -f ${composeFile} up";
          ExecStop = "${pkgs.podman}/bin/podman compose -f ${composeFile} down";
          Restart = "on-failure";
        };
      }
      // (
        if enable
        then {
          Install.WantedBy = ["podman-init.target"];
        }
        else {}
      );
  };

  mkAgenix = {
    name,
    user,
    envPath,
    dbPath ? null,
  }: {
    age = {
      identityPaths = ["/home/${user}/.ssh/containers/${name}"];
      secrets =
        {
          "${name}-env" = {
            file = "${envPath}";
            owner = "${user}";
            group = "users";
            mode = "0400";
          };
        }
        // lib.optionalAttrs (dbPath != null) {
          "${name}-db" = {
            file = "${dbPath}";
            owner = "${user}";
            group = "users";
            mode = "0400";
          };
        };
    };
  };
}
