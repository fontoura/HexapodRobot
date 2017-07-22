/*
 * thread.cpp
 *
 *  Created on: 25/03/2013
 *      Author: Felipe Michels Fontoura
 */

#ifdef _WIN32

#include "thread.h"
#include <windows.h>

namespace native
{
	namespace win32
	{
		bool thread_create(HANDLE& hThread, DWORD WINAPI (*function)(LPVOID), void* parameter)
		{
			HANDLE handle = ::CreateThread(NULL, 0, function, parameter, CREATE_SUSPENDED, NULL);
			hThread = handle;
			return handle != INVALID_HANDLE_VALUE;
		}

		bool thread_destroy(HANDLE& hThread)
		{
			HANDLE handle = hThread;
			if (handle != INVALID_HANDLE_VALUE)
			{
				if (::CloseHandle(hThread))
				{
					hThread = INVALID_HANDLE_VALUE;
					return true;
				}
				else
				{
					return false;

				}
			}
			else
			{
				return false;
			}
		}

		bool thread_resume(HANDLE hThread)
		{
			return (DWORD)-1 != ::ResumeThread(hThread);

		}
		bool thread_join(HANDLE hThread, long millis)
		{
			if (hThread != INVALID_HANDLE_VALUE)
			{
				if (millis >= 0)
				{
					return WAIT_OBJECT_0 == ::WaitForSingleObject(hThread, millis);
				}
				else
				{
					return WAIT_OBJECT_0 == ::WaitForSingleObject(hThread, INFINITE);
				}
			}
			else
			{
				return true;
			}
		}

		bool thread_sleep(long millis)
		{
			if (millis < 0)
			{
				return false;
			}
			else
			{
				if (millis > 0)
				{
					::Sleep(millis);
				}
				return true;
			}
		}
	}
}

#endif /* _WIN32 */
