{ lib
, stdenv
, fetchurl
, substitute
, writeText
, symlinkJoin
, fetchMavenArtifact

, minecraft-jars
, unzip
}:

{
  lockFile,
}:

let
  inherit (builtins)
    attrValues
    elemAt
    filter
    fromJSON
    getAttr
    head
    length
    map
    replaceStrings
    ;

  lock = fromJSON(readFile lockFile);

  inherit (lib) mapAttrsToList readFile;
  inherit (lib.strings) sanitizeDerivationName;

  escapeVersion = builtins.replaceStrings [ "." ] [ "_" ];

  mkVersionEntry = version:
    let
      manifest = minecraft-jars.${escapeVersion version.version}.manifest-info;
    in
  {
    inherit (manifest) url sha1;
    id = version.version;
  };

  mkVersion = version:
    let
      version-info = minecraft-jars.${escapeVersion version.version};
      inherit (version-info) client server manifest;

      intermediaryUrl = "https://maven.fabricmc.net/net/fabricmc/intermediary/${version.version}/intermediary-${version.version}-v2.jar";

      intermediary = stdenv.mkDerivation {
        name = "${version.version}-intermediary-v2.tiny";
        ver = version.version;
        src = version-info.intermediary;
        dontPatch = true;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        unpackCmd = ''${unzip}/bin/unzip "$src" "mappings/mappings.tiny"'';

        installPhase = ''
        cp mappings.tiny $out
        '';
      };
    in
      stdenv.mkDerivation {
        name = version.version;
        dontUnpack = true;
        dontPatch = true;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        clientJar = client;
        serverJar = server;
        minecraftInfo = manifest;
        inherit intermediary;

        installPhase = ''
        mkdir -p $out/$name
        ln -s $clientJar $out/$name/minecraft-client.jar
        ln -s $serverJar $out/$name/minecraft-server.jar
        ln -s $minecraftInfo $out/$name/minecraft-info.json
        ln -s $minecraftInfo $out/$name/mojang_minecraft_info.json
        ln -s $intermediary $out/$name/intermediary-v2.tiny
        '';
      };

  loomCachePaths = map mkVersion lock.minecraftVersions;

  versionManifest =
  let
    manifest = writeText "version_manifest.json"
      (builtins.toJSON {
        versions = map mkVersionEntry lock.minecraftVersions;
        latest = {};
      });
  in
    stdenv.mkDerivation {
      name = "version-manifests";
      dontUnpack = true;
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      versionsManifest = manifest;

      # Install to several different paths to ensure compatibility with different loom versions
      installPhase = ''
      mkdir -p $out
      ln -s $versionsManifest $out/version_manifest.json
      ln -s $versionsManifest $out/versions_manifest.json
      ln -s $versionsManifest $out/mojang_versions_manifest.json
      '';
    };

  loomCache = symlinkJoin {
    name = "fabric-loom-cache";
    paths = loomCachePaths ++ [versionManifest];
  };
in
loomCache
