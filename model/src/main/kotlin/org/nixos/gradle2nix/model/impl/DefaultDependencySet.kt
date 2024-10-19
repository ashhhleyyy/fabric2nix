package org.nixos.gradle2nix.model.impl

import org.nixos.gradle2nix.model.DependencySet
import org.nixos.gradle2nix.model.MinecraftVersion
import org.nixos.gradle2nix.model.ResolvedDependency

data class DefaultDependencySet(
    override val dependencies: List<ResolvedDependency>,
    override val minecraftVersions: List<MinecraftVersion>,
) : DependencySet
