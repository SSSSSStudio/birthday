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
			"Tw2Library",
			"LuaLibrary",
			"LuaProjectLibrary",
			"LuaTlsLibrary",
			"LuaCryptLibrary",
			"LuaJsonLibrary",
			"LuaXmlLibrary",
			"LuaLPegLibrary",
			"LuaPbcLibrary",
			"LuaMsgpackLibrary",
			"LuaWSProtoLibrary",
			"LuaHParserLibrary",
			"LuaTw2Library",
			"LuaExtension",
			"UnLua",
			"WebSockets",
			"HTTP"
		});

		PrivateIncludePaths.AddRange(new string[]
		{
			"G01/Public"
		});		
		
	}
}
