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

	if (flags & TW2_WRITER_BINARY)
	{
		if (flags & TW2_WRITER_CHANGE)
		{
			mode |= FILEREAD_None;
			mode |= FILEREAD_AllowWrite;
		}
		else if (flags & TW2_WRITER_APPEND)
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
		if (flags & TW2_WRITER_CHANGE)
		{
			mode |= FILEREAD_None;
			mode |= FILEREAD_AllowWrite;
		}
		else if (flags & TW2_WRITER_APPEND)
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
	tw2_io_vtable_t io_vtable;
	io_vtable.createReader = create_reader;
	io_vtable.createWriter = create_writer;
	io_vtable.archiveTell = archive_tell;
	io_vtable.archiveSize = archive_size;
	io_vtable.archiveSerialize = archive_serialize;
	io_vtable.archiveFlush = archive_flush;
	io_vtable.archiveSeek = archive_seek;
	io_vtable.archiveClose = archive_close;

	tw2_io_reset_file_functions(&io_vtable);
	tw2_set_log_custom_print([](tw2_log_level_t e, const char* s)
	{
		switch (e)
		{
		case TW2_LOG_LEVEL_INFO:
			{
				UE_LOG(LogTemp, Log, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case TW2_LOG_LEVEL_WARNING:
			{
				UE_LOG(LogTemp, Warning, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case TW2_LOG_LEVEL_ERROR:
			{
				UE_LOG(LogTemp, Error, TEXT("%s"), UTF8_TO_TCHAR(s));
			}
			break;
		case TW2_LOG_LEVEL_FATAL:
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
