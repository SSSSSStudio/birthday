using System.IO;
using UnrealBuildTool;

public class LuaProjectLibrary : ModuleRules
{
    public LuaProjectLibrary(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

        PublicDependencyModuleNames.AddRange(new string[] { "Core" });

		PrivateDependencyModuleNames.AddRange(new string[] { "LuaLibrary"});

		PublicDefinitions.Add("WITH_LuaProjectLibrary=1");

		PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Source"));		
    }
}
