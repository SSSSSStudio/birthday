// Copyright Epic Games, Inc. All Rights Reserved.

#include "LuaExtension.h"
#include "Misc/MessageDialog.h"
#include "Modules/ModuleManager.h"
#include "Interfaces/IPluginManager.h"
#include "Misc/Paths.h"
#include "HAL/PlatformProcess.h"


extern "C" {
	#include "io_tt.h"
	#include "log_tt.h"
}


struct tw2_archive_s
{
	TSharedPtr<FArchive> archive;
};

static tw2_archive_t* create_reader(const char* filename)
{
	FString FullPathFile = FPaths::Combine(FPaths::ConvertRelativePathToFull(FPaths::ProjectContentDir()),UTF8_TO_TCHAR(filename));

	FArchive* pArchive = IFileManager::Get().CreateFileReader(*FullPathFile, 0);
	if(pArchive == nullptr)
	{
		return nullptr;
	}

	tw2_archive_t* p = new tw2_archive_t;
	p->archive = MakeShareable(pArchive);
	return p;
}

static tw2_archive_t* create_writer(const char* filename, uint32_t flags)
{
	FString FullPathFile = FPaths::Combine(FPaths::ConvertRelativePathToFull(FPaths::ProjectContentDir()),UTF8_TO_TCHAR(filename));

	uint32_t mode = 0;

	if (flags & WRITER_BINARY)
	{
		if (flags & WRITER_CHANGE)
		{
			mode |= FILEREAD_None;
			mode |= FILEREAD_AllowWrite;
		}
		else if (flags & WRITER_APPEND)
		{
			mode |= FILEWRITE_Append;
		}
		else
		{
			mode |= FILEWRITE_None;
		}
	}
	else
	{
		if (flags & WRITER_CHANGE)
		{
			mode |= FILEREAD_None;
			mode |= FILEREAD_AllowWrite;
		}
		else if (flags & WRITER_APPEND)
		{
			mode |= FILEWRITE_Append;
		}
		else
		{
			mode |= FILEWRITE_None;
		}
	}

	FArchive* pArchive = IFileManager::Get().CreateFileWriter(*FullPathFile, mode);
	if(pArchive == nullptr)
	{
		return nullptr;
	}

	tw2_archive_t* p = new tw2_archive_t;
	p->archive = MakeShareable(pArchive);
	return p;
}

static void archive_flush(tw2_archive_t* pHandle)
{
	pHandle->archive->Flush();
}

static void archive_serialize(tw2_archive_t* pHandle, void* w, size_t length)
{
	pHandle->archive->Serialize(w,(int64_t)length);
}

static size_t archive_tell(tw2_archive_t* pHandle)
{
	return (size_t)pHandle->archive->Tell();
}

static void archive_seek(tw2_archive_t* pHandle, size_t offset)
{
	pHandle->archive->Seek((int)offset);
}

static size_t archive_size(tw2_archive_t* pHandle)
{
	return (size_t)pHandle->archive->TotalSize();
}

static void archive_close(tw2_archive_t* pHandle)
{
	pHandle->archive.Reset();
	delete pHandle;
}

#define LOCTEXT_NAMESPACE "FLuaExtensionModule"

void FLuaExtensionModule::StartupModule()
{
	tw2_io_reset_file_functions(create_reader,create_writer,archive_tell,archive_size,archive_serialize,archive_flush,archive_seek,archive_close);
	tw2_set_log_custom_print([](enLogLevel e, const char* s)
	{
		switch (e)
		{
		case eLogLevelInfo:
			{
				UE_LOG(LogTemp, Log, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case eLogLevelWarning:
			{
				UE_LOG(LogTemp, Warning, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case eLogLevelError:
			{
				UE_LOG(LogTemp, Error, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case eLogLevelFatal:
			{
				UE_LOG(LogTemp, Fatal, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		}
	});
}

void FLuaExtensionModule::ShutdownModule()
{

}

#undef LOCTEXT_NAMESPACE
	
IMPLEMENT_MODULE(FLuaExtensionModule, LuaExtension)
