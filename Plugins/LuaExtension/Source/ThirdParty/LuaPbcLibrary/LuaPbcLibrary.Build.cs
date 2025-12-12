using System;
using System.IO;
using UnrealBuildTool;

public class LuaPbcLibrary : ModuleRules
{
	public LuaPbcLibrary(ReadOnlyTargetRules Target) : base(Target)
	{
		Type = ModuleType.External;

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/lpbc.lib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/liblpbc.dylib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/liblpbc.so"));
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/liblpbc.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/liblpbc.a"));
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/liblpbc.a"));
		}

		PublicSystemIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));
	}
}