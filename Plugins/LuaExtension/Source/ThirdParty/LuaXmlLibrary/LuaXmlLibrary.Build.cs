using System;
using System.IO;
using UnrealBuildTool;

public class LuaXmlLibrary : ModuleRules
{
	public LuaXmlLibrary(ReadOnlyTargetRules Target) : base(Target)
	{
		Type = ModuleType.External;

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/lxml.lib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/liblxml.dylib"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/liblxml.so"));
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/liblxml.a"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Android)
		{
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/liblxml.a"));
			PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/liblxml.a"));
		}

		PublicSystemIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));
	}
}