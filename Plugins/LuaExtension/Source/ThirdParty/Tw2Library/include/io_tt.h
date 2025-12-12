/*  tw2
 *  Copyright (C) 2019  Peng Bo <pengbo@twtwo.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as published
 *  by the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "utility_tt.h"

enum
{
	WRITER_BINARY = 0x01,
	WRITER_APPEND = 0x02,
	WRITER_CHANGE = 0x04,
};

struct tw2_archive_s;
typedef struct tw2_archive_s tw2_archive_t;

tw2_API bool tw2_io_mkdir(const char* path);

tw2_API bool tw2_io_rmdir(const char* path);

tw2_API bool tw2_io_remove(const char* path);

tw2_API bool tw2_io_rename(const char* oldname, const char* newname);

tw2_API bool tw2_io_find_file(const char* filename);

tw2_API bool tw2_io_remove_file(const char* filename);

tw2_API void tw2_io_reset_file_functions(tw2_archive_t* (*createReader)(const char*),
	tw2_archive_t* (*createWriter)(const char*,uint32_t ),
	size_t (*archiveTell)(tw2_archive_t*),
	size_t (*archiveSize)(tw2_archive_t*),
	void (*archiveSerialize)(tw2_archive_t*,void*,size_t),
	void (*archiveFlush)(tw2_archive_t*),
	void (*archiveSeek)(tw2_archive_t*,size_t),
	void (*archiveClose)(tw2_archive_t*));

tw2_API tw2_archive_t* tw2_io_create_reader(const char* filename);

tw2_API tw2_archive_t* tw2_io_create_writer(const char* filename, uint32_t flags);

tw2_API size_t tw2_archive_tell(tw2_archive_t* pHandle);

tw2_API size_t tw2_archive_size(tw2_archive_t* pHandle);

tw2_API void tw2_archive_serialize(tw2_archive_t* pHandle, void* w, size_t length);

tw2_API void tw2_archive_seek(tw2_archive_t* pHandle, size_t offset);

tw2_API void tw2_archive_flush(tw2_archive_t* pHandle);

tw2_API bool tw2_archive_end(tw2_archive_t* pHandle);

tw2_API void tw2_archive_close(tw2_archive_t* pHandle);
