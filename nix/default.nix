{
  lib,
  gradle,
  newScope,
  minecraft-jars,
}:

lib.makeScope newScope (
  self: with self; {
    inherit gradle;
    buildGradlePackage = callPackage ./build-gradle-package.nix { };
    buildMavenRepo = callPackage ./build-maven-repo.nix { };
    buildLoomCaches = callPackage ./build-loom-caches.nix { inherit minecraft-jars; };
    gradleSetupHook = callPackage ./gradle-setup-hook.nix { };
    gradle2nix = callPackage ./gradle2nix.nix { };
  }
)
