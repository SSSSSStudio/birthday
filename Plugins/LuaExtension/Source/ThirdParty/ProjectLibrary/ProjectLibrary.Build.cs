using System.IO;
using UnrealBuildTool;

public class ProjectLibrary : ModuleRules
{
    public ProjectLibrary(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

        PublicDependencyModuleNames.AddRange(new string[] { "Core" });

		PrivateDependencyModuleNames.AddRange(new string[] { "LuaLibrary"});

		PublicDefinitions.Add("WITH_ProjectLibrary=1");

		PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Source"));		
    }
}
