// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class G01 : ModuleRules
{
	public G01(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
	
		PublicDependencyModuleNames.AddRange(new string[]
		{
			"Core", 
			"CoreUObject", 
			"Engine", 
			"InputCore", 
			"EnhancedInput",
			"GameplayTags",
			
			
		});

		PrivateDependencyModuleNames.AddRange(new string[]
		{
			"UMG",
			"Slate",
			"SlateCore",
		});

		PrivateIncludePaths.AddRange(new string[]
		{
			"Public"
		});		
		
	}
}
