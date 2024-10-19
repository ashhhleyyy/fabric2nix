package org.nixos.gradle2nix

import org.gradle.api.Plugin
import org.gradle.api.internal.artifacts.ivyservice.modulecache.FileStoreAndIndexProvider
import org.gradle.api.invocation.Gradle
import org.gradle.internal.hash.ChecksumService
import org.gradle.tooling.provider.model.ToolingModelBuilderRegistry
import org.nixos.gradle2nix.model.MinecraftVersion
import org.nixos.gradle2nix.model.impl.DefaultMinecraftVersion

abstract class AbstractGradle2NixPlugin(
    private val cacheAccessFactory: GradleCacheAccessFactory,
    private val dependencyExtractorApplier: DependencyExtractorApplier,
    private val resolveAllArtifactsApplier: ResolveAllArtifactsApplier,
) : Plugin<Gradle> {
    override fun apply(gradle: Gradle) {
        val extractor = DependencyExtractor()
        val minecraftVersions = mutableListOf<MinecraftVersion>()

        gradle.service<ToolingModelBuilderRegistry>().register(
            DependencySetModelBuilder(
                extractor,
                cacheAccessFactory.create(gradle),
                gradle.service<ChecksumService>(),
                gradle.service<FileStoreAndIndexProvider>(),
                minecraftVersions,
            ),
        )

        dependencyExtractorApplier.apply(gradle, extractor)

        gradle.projectsEvaluated {
            resolveAllArtifactsApplier.apply(gradle)

            gradle.allprojects { project ->
                if (project.configurations.any { it.name == "minecraft" } && project.configurations.any { it.name == "mappings" }) {
                    val minecraftDependencies = project.configurations.getByName("minecraft").dependencies
                    if (minecraftDependencies.isEmpty()) {
                        error("`minecraft` dependency not specified")
                    }
                    if (minecraftDependencies.size > 1) {
                        error("multiple `minecraft` dependencies specified")
                    }
                    val minecraftDependency = minecraftDependencies.iterator().next()
                    if (minecraftDependency.group != "com.mojang" || minecraftDependency.name != "minecraft") {
                        error("minecraft dependency must be `com.mojang:minecraft`")
                    }
                    minecraftVersions.add(
                        DefaultMinecraftVersion(
                            minecraftDependency.version ?: error("missing version for minecraft dependency"),
                        ),
                    )
                }
            }
        }
    }
}
