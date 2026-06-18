{
  description = "Podman service helpers";

  outputs = {
    nixosModules.default = import ./nixos.nix;
    homeModules.default = import ./user.nix;
    homeModules.lib = {
      pkgs,
      lib,
    }:
      import ./lib.nix {inherit pkgs lib;};
  };
}
