
using System;
using System.IO;
using UnrealBuildTool;

public class Tw2Library : ModuleRules
{
    public Tw2Library(ReadOnlyTargetRules Target) : base(Target)
    {
        Type = ModuleType.External;

        if (Target.Platform == UnrealTargetPlatform.Win64)
        {
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory,"lib/Win64/tw2.lib"));
        }
        else if (Target.Platform == UnrealTargetPlatform.Mac)
        {
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Mac/libtw2.dylib"));
        }
        else if (Target.Platform == UnrealTargetPlatform.Linux)
        {
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Linux/libtw2.so"));
        }
        else if (Target.Platform == UnrealTargetPlatform.IOS)
        {
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/iOS/libtw2.a"));
        }
        else if (Target.Platform == UnrealTargetPlatform.Android)
        {
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARMv7/libtw2.a"));
            PublicAdditionalLibraries.Add(Path.Combine(ModuleDirectory, "lib/Android/ARM64/libtw2.a"));
        }
    }
}
