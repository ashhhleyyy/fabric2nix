{
  description = "Wrap Gradle builds with Nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-fabric = {
      url = "github:ashhhleyyy/nix-fabric";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      nix-fabric,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        minecraft-jars = nix-fabric.packages.${system}.minecraft-jars;
        scope = pkgs.callPackage ./nix {
          inherit minecraft-jars;
        };
        inherit (nixpkgs) lib;
      in
      {
        builders = {
          inherit (scope) buildGradlePackage buildMavenRepo buildLoomCaches;
          default = self.packages.${system}.buildGradlePackage;
        };

        packages = {
          inherit (scope) gradle2nix gradleSetupHook;
          default = self.packages.${system}.gradle2nix;
        };

        apps = {
          gradle2nix = {
            type = "app";
            program = lib.getExe self.packages.${system}.gradle2nix;
          };
          default = self.apps.${system}.gradle2nix;
        };

        formatter = pkgs.writeShellScriptBin "gradle2nix-fmt" ''
          fail=0
          ${lib.getExe pkgs.nixfmt-rfc-style} $@ || fail=1
          ${lib.getExe pkgs.git} ls-files -z '*.kt' '*.kts' | ${lib.getExe pkgs.ktlint} --relative -l warn -F --patterns-from-stdin= || fail=1
          [ $fail -eq 0 ] || echo "Formatting failed." >&2
          exit $fail
        '';
      }
    );
}
