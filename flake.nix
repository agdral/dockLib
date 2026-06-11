{
  description = "Podman service helpers";

  outputs = {self}: {
    lib = {
      pkgs,
      lib,
    }:
      import ./lib.nix {inherit pkgs lib;};
    nixosModules.default = {
      imports = [
        ./user.nix
        ./podman.nix
      ];
    };
  };
}
