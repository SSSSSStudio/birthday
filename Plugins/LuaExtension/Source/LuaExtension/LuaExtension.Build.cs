// Copyright Epic Games, Inc. All Rights Reserved.
using System.IO;
using UnrealBuildTool;

public class LuaExtension : ModuleRules
{
	public LuaExtension(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
		
		PublicIncludePaths.AddRange(
			new string[] {
				// ... add public include paths required here ...
			}
			);
				
		
		PrivateIncludePaths.AddRange(
			new string[] {
				// ... add other private include paths required here ...
			}
			);
			
		
		PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
				"CoreUObject",
				"Projects"
				// ... add other public dependencies that you statically link with here ...
			}
			);
			
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				// ... add private dependencies that you statically link with here ...	
			}
			);
		
		
		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);
		
		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaJsonLibrary", "bin/Win64"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
        {
	        DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaJsonLibrary", "bin/Linux"));
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
        {
	        DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaJsonLibrary", "bin/Mac"));
		}
	}
	
	void DependDll(string path)
	{
		if (Directory.Exists(path))
		{
			DirectoryInfo root = new DirectoryInfo(path);
			FileInfo[] files = root.GetFiles();
			foreach (FileInfo f in files)
			{
				if ((f.FullName.ToLower().EndsWith(".dll")|| f.FullName.ToLower().EndsWith(".so")|| f.FullName.ToLower().EndsWith(".dylib")) && File.Exists(f.FullName))
				{
					var targetPath = Path.Combine("$(BinaryOutputDir)", f.Name);
					var targetPath2 = Path.Combine("$(TargetOutputDir)", f.Name);
					var fromPath = f.FullName;
					RuntimeDependencies.Add(targetPath, fromPath);
					RuntimeDependencies.Add(targetPath2, fromPath);
				}
				System.Console.WriteLine(f.FullName);
			}
		}
	}
}
