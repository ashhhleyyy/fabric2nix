package org.nixos.gradle2nix.model

import java.io.Serializable

interface MinecraftVersion : Serializable {
    val gameVersion: String
}
