/*
 * semaphore.cpp
 *
 *  Created on: 23/03/2013
 */

#ifdef __WIN32__

#include "semaphore.h"
#include <windows.h>
#include <ntdef.h>

#define SEMAQUERYINFOCLASS 0

extern "C"
{
	typedef struct
	{
		UINT Count;
		UINT Limit;
	} SEMAINFO, *PSEMAINFO;

	NTSTATUS WINAPI NtQuerySemaphore(HANDLE Handle, UINT InfoClass, PSEMAINFO SemaInfo, UINT InfoSize, PUINT RetLen);

	BOOL WINAPI QuerySemaphore(HANDLE hSemaphore, LPLONG lpCount)
	{
		SEMAINFO SemInfo;
		UINT RetLen;
		NTSTATUS Status;

		Status = NtQuerySemaphore(hSemaphore, SEMAQUERYINFOCLASS, &SemInfo, sizeof(SemInfo), &RetLen);

		if (!NT_SUCCESS(Status))
		{
			*lpCount = -1;
			return FALSE;
		}
		else
		{
			*lpCount = SemInfo.Count;
			return TRUE;
		}
	}
}

namespace native
{
	namespace win32
	{
		bool semaphore_create(HANDLE& hSemaphore, int count, int maximum)
		{
			HANDLE handle = ::CreateSemaphoreA(NULL, count, maximum, NULL);
			hSemaphore = handle;
			return handle != INVALID_HANDLE_VALUE;
		}

		bool semaphore_destroy(HANDLE& hSemaphore)
		{
			HANDLE handle = hSemaphore;
			if (handle != INVALID_HANDLE_VALUE)
			{
				::CloseHandle(handle);
			}
			hSemaphore = INVALID_HANDLE_VALUE;
			return handle != INVALID_HANDLE_VALUE;
		}

		bool semaphore_down(HANDLE hSemaphore, long millis)
		{
			HANDLE handle = hSemaphore;
			if (handle != INVALID_HANDLE_VALUE)
			{
				if (millis >= 0)
				{
					return ::WaitForSingleObject(handle, millis) == WAIT_OBJECT_0;
				}
				else
				{
					return ::WaitForSingleObject(handle, INFINITE) == WAIT_OBJECT_0;
				}
			}
			else
			{
				return false;
			}
		}

		bool semaphore_up(HANDLE hSemaphore)
		{
			HANDLE handle = hSemaphore;
			if (handle != INVALID_HANDLE_VALUE)
			{
				return ::ReleaseSemaphore(handle, 1, NULL);
			}
			else
			{
				return false;
			}
		}

		bool semaphore_query(HANDLE hSemaphore, int* count)
		{
			LONG query = 0;
			HANDLE handle = hSemaphore;
			if (handle != INVALID_HANDLE_VALUE)
			{
				if (::QuerySemaphore(handle, &query))
				{
					*count = (int)query;
					return true;
				}
				else
				{
					*count = -1;
					return false;
				}
			}
			else
			{
				*count = -1;
				return false;
			}
		}
	}
}

#endif /* __WIN32__ */
