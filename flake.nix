{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, ... }: let
    forAllSystems = function:
    nixpkgs.lib.genAttrs (import systems) (
      system: function nixpkgs.legacyPackages.${system}
    );
  in
  {
    packages = forAllSystems (pkgs: {
      default = pkgs.callPackage ./shell.nix { };
    });
  };
}