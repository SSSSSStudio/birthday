using System;
using System.IO;
using UnrealBuildTool;

public class LuaFixedLibrary : ModuleRules
{
	public LuaFixedLibrary(ReadOnlyTargetRules Target) : base(Target)
	{
		Type = ModuleType.External;

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/lfixed.lib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/lfixed.dylib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/lfixed.so"));
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/lfixed.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/lfixed.a"));
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/lfixed.a"));
		}

		PublicSystemIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));
	}
}