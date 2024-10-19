package org.nixos.gradle2nix

import kotlinx.serialization.Serializable

@Serializable
data class Env internal constructor(
    val mavenDependencies: Map<String, Map<String, Artifact>>,
    val minecraftVersions: List<MinecraftArtifact>,
)

@Serializable
data class Artifact internal constructor(
    val url: String,
    val hash: String,
)

@Serializable
data class MinecraftArtifact internal constructor(
    val version: String,
)
