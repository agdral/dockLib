{
  pkgs,
  lib,
}: {
  mkPodmanService = {
    name,
    composeFile,
    enable ? true,
  }: {
    systemd.user.services.${name} =
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
    user ? "podcal",
    envPath,
    dbPath ? null,
  }: {
    age = {
      identityPaths = ["/home/${user}/.ssh/containers/${name}"];
      secrets =
        {
          "${name}-env".file = "${envPath}";
        }
        // lib.optionalAttrs (dbPath != null) {
          "${name}-db".file = "${dbPath}";
        };
    };
  };
}
