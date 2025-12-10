// Fill out your copyright notice in the Description page of Project Settings.

using System.IO;
using UnrealBuildTool;

public class LuaCryptLibrary : ModuleRules
{
	public LuaCryptLibrary(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] { "Core" });

		PrivateDependencyModuleNames.AddRange(new string[] { "LuaLibrary", "OpenSSL" });

		PublicDefinitions.Add("WITH_LuaCryptLibrary=1");
		
		PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Source"));		
	}
}