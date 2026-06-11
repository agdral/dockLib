{
  description = "Podman service helpers";

  outputs = {self}: {
    lib = {
      pkgs,
      lib,
    }:
      import ./lib.nix {inherit pkgs lib;};
    nixosModules.default.import = ./nixos.nix;
    homeModules.default.import = ./home.nix;
  };
}
