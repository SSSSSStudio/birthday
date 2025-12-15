using System;
using System.IO;
using UnrealBuildTool;

public class LuaHParserLibrary : ModuleRules
{
	public LuaHParserLibrary(ReadOnlyTargetRules Target) : base(Target)
	{
		Type = ModuleType.External;

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/lhparser.lib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/liblhparser.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/liblhparser.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/liblhparser.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/liblhparser.a"));
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/liblhparser.a"));
		}
		PublicSystemIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));
	}
}