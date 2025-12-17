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
				"Projects",
				"Tw2Library",
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
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLPegLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaXmlLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "Tw2Library", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaTw2Library", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaWSProtoLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaMsgpackLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaHParserLibrary", "bin/Win64"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaPbcLibrary", "bin/Win64"));
			
		}
		else if (Target.Platform == UnrealTargetPlatform.Linux)
        {
	        DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaJsonLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLPegLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaXmlLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "Tw2Library", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaTw2Library", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaWSProtoLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaMsgpackLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaHParserLibrary", "bin/Linux"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaPbcLibrary", "bin/Linux"));
			
		}
		else if (Target.Platform == UnrealTargetPlatform.Mac)
        {
	        DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaJsonLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaLPegLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaXmlLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "Tw2Library", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaTw2Library", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaWSProtoLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaMsgpackLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaHParserLibrary", "bin/Mac"));
			DependDll(Path.Combine(ModuleDirectory, "../", "../", "Source/ThirdParty/", "LuaPbcLibrary", "bin/Mac"));
			
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
