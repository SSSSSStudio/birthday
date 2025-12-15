using System;
using System.IO;
using UnrealBuildTool;

public class LuaTw2Library : ModuleRules
{
	public LuaTw2Library(ReadOnlyTargetRules Target) : base(Target)
	{
		Type = ModuleType.External;

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/ltw2.lib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/libltw2.dylib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/libltw2.so"));
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/libltw2.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/libltw2.a"));
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/libltw2.a"));
		}

		PublicSystemIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));
	}
}