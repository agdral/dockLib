{
  description = "Podman service helpers";

  outputs = {self}: {
    lib = {
      pkgs,
      lib,
    }:
      import ./. {inherit pkgs lib;};
  };
}
