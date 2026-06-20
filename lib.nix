{
  pkgs,
  lib,
}: {
  mkPodmanService = {
    name,
    composeFile,
    enable ? true,
    dependsOn ? [],
  }: let
    waitScript = pkgs.writeShellScript "wait-for-containers" ''
      set -e
      for container in "$@"; do
        echo "Esperando que $container esté saludable..."
        ${pkgs.podman}/bin/podman wait --condition=healthy "$container"
        echo "$container está saludable!"
      done
    '';
  in {
    systemd.user.services.${name} =
      {
        Unit.PartOf = ["podman-init.target"];
        Service = {
          ExecStartPre =
            if dependsOn != []
            then "${waitScript} ${toString dependsOn}"
            else "";
          ExecStart = "${pkgs.podman}/bin/podman compose -f ${composeFile} up";
          ExecReload = "${pkgs.podman}/bin/podman compose -f ${composeFile} down";
          ExecStop = "${pkgs.podman}/bin/podman compose -f ${composeFile} stop";
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
