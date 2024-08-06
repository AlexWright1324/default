{
  description = "git clone https://github.com/AlexWright1324/default.git <NAME> && rm -rf $_/.git";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    just-flake.url = "github:juspay/just-flake";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.just-flake.flakeModule
      ];

      systems = import inputs.systems;

      perSystem =
        { config, pkgs, ... }:
        {
          pre-commit.settings.hooks = {
            nil.enable = true;
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };
          };

          just-flake.features = { };

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.pre-commit.devShell
              config.just-flake.outputs.devShell
            ];
            packages = with pkgs; [ ];
          };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
