package org.nixos.gradle2nix.model.impl

import org.nixos.gradle2nix.model.MinecraftVersion

data class DefaultMinecraftVersion(
    override val gameVersion: String
) : MinecraftVersion
